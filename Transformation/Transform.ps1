param(
    [Parameter(Mandatory=$true)]
    [string]$InputFile,
    
    [Parameter(Mandatory=$true)]
    [string]$OutputFile,

    [Parameter(Mandatory=$true)]
    [string]$Script,

    [string]$Passkey,

    [switch]$SkipEncrypted
)

$ErrorActionPreference = "Stop"

$includes = New-Object "System.Collections.Generic.HashSet[string]([System.StringComparer]::OrdinalIgnoreCase)"
$nodes = New-Object "System.Collections.Generic.Dictionary[string, System.Xml.XmlNode]"

function Where-Element() {
    return $Input | Where-Object { $_.NodeType -eq [System.Xml.XmlNodeType]::Element }
}

# Recursively traverses includes from the transformation scripts and fills the collection of nodes.
function Update-Nodes([string]$Script) {
    $Script = [System.IO.Path]::GetFullPath($Script)

    Write-Verbose "Processing script `"$Script`""

    if ($includes.Contains($Script)) {
        return
    }

    $includes.Add($Script) | Out-Null

    [Xml]$data = Get-Content $Script -ErrorAction Stop

    ForEach ($node in $data.data.nodes.ChildNodes | Where-Element) {
        Write-Verbose "Processing node $($node.OuterXml)"

        if ($nodes.ContainsKey($node._name)) {
            throw "The node `"$($node._name)`" already existed in the collection when processed the `"$Script`" script."
        }

        $nodes.Add($node._name, $node)
    }

    ForEach ($include in $data.data.include) {
        $includePath = $include.path

        if (-not [System.IO.Path]::IsPathRooted($includePath)) {
            $includePath = Join-Path ([System.IO.Path]::GetDirectoryName($Script)) $includePath
        }

        Update-Nodes -Script $includePath
    }
}

Update-Nodes -Script $Script

function Get-MergedNode([System.Xml.XmlNode]$Source, [System.Xml.XmlNode]$Target) {
    ForEach ($attr in $Source.Attributes) {
        if ($attr.Name -ne "_name") {
            $Target.SetAttribute($attr.Name, $attr.Value)
        }
    }

    if (-not $Target._xpath) {
        throw "Cannot determine an XPath of the node `"$Name`"."
    }

    if ($Source.InnerXml) {
        $Target.InnerXml = $Source.InnerXml
    }

    return $Target
}

# Gets the node with specified name, flattened through the whole inheritance hierarchy.
function Get-Node([System.Xml.XmlNode]$Node) {
    if ($Node.Name -eq "_parameter") {
        return $Node.Clone()
    }

    [System.Xml.XmlNode]$parent = $null

    if (-not $nodes.TryGetValue($Node.Name, [ref]$parent)) {
        throw "Could not find a node with name `"$($Node.Name)`"."
    }

    $result = Get-MergedNode -Source $parent -Target (Get-Node -Node $parent)
    
    $nodes.Remove($Node.Name) | Out-Null
    $nodes.Add($Node.Name, $result)

    return $result
}

# Performs cleanup of the target node and returns a value indicating whether the node has been removed.
function Update-CleanupTarget([System.Xml.XmlNode]$Node, [System.Xml.XmlNode]$Target) {
    $attrPrefix = "_remove-"

    ForEach ($attr in $Node.Attributes) {
        if (($attr.Name -eq "_remove") -and ([System.Boolean]::Parse($attr.Value))) {
            switch ($Target.NodeType) {
                Element {
                    $Target.ParentNode.RemoveChild($Target)
                }
                Attribute {
                    [System.Xml.XmlAttribute]$attr = $Target
                    $attr.OwnerElement.RemoveAttributeNode($attr)
                }
                default {
                    throw "Could not remove the node of unsupported type $($Target.NodeType)."
                }
            }

            return $true
        }
        elseif ($attr.Name.StartsWith($attrPrefix) -and ([System.Boolean]::Parse($attr.Value))) {
            $attrName = $attr.Name.Substring($attrPrefix.Length)
            [System.Xml.XmlAttribute]$attr = $Target.Attributes.GetNamedItem($attrName)

            if ($attr) {
                $Target.Attributes.Remove($attr)
            }
            else {
                Write-Warning "The attribute `"$attrName`" could not be found, and thus has not been removed."
            }
        }
    }
}

function Update-RedirectTarget([System.Xml.XmlElement]$Node, [System.Xml.XmlElement]$Target, [Xml]$Document) {
    $attr = $Node.Attributes.GetNamedItem("_create-or-update")

    if (-not $attr) {
        return $Target
    }

    [System.Xml.XmlNodeList]$elements = $Target.GetElementsByTagName($attr.Value)

    switch ($elements.Count) {
        0 {
            $child = $Document.CreateElement($attr.Value)
            $Target.AppendChild($child) | Out-Null
            return $child
        }
        1 {
            return $elements.Item(0)
        }
        default {
            throw "Found $($elements.Count) child elements of the name `"$($attr.Value)`", but expected a single element."
        }
    }
}

# Decrypts provided value if necessary.
function Get-DecryptedString([System.Xml.XmlNode]$Node, [string]$AttributName, [string]$Value) {
    if ($SkipEncrypted) {
        return $Value
    }

    $encrNode = $node.Attributes.GetNamedItem($AttributName)

    if ($encrNode -and [System.Boolean]::Parse($encrNode.Value)) {
        # Use 'ConvertTo-SecureString "<value>" -AsPlainText -Force | ConvertFrom-SecureString' to obtain the value.
        if ($Passkey) {
            $str = ConvertTo-SecureString $Value.Trim() -Key ([System.Convert]::FromBase64String($Passkey))
        }
        else {
            $str = ConvertTo-SecureString $Value
        }

        $bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($str)
        return [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)
    }

    return $Value
}

[Xml]$scriptXml = Get-Content $Script -ErrorAction Stop
[Xml]$inputXml = Get-Content $InputFile -ErrorAction Stop

ForEach ($value in $scriptXml.data.values.ChildNodes | Where-Element) {
    $node = Get-MergedNode -Source $value -Target (Get-Node -Node $value)

    Write-Verbose -Message "Finding elements by XPath `"$($node._xpath)`"."

    $targets = $inputXml.SelectNodes($node._xpath)

    if ($targets.Count -eq 0) {
        Write-Warning -Message "No XML nodes have been found for the value `"$($value.Name)`"."
    }

    ForEach ($target in $targets) {
        if ($target.NodeType -eq [System.Xml.XmlNodeType]::Element) {
            $target = Update-RedirectTarget -Node $node -Target $target -Document $inputXml
        }

        if (Update-CleanupTarget -Node $node -Target $target) {
            continue
        }

        ForEach ($attr in $node.Attributes | Where-Object { -not $_.Name.StartsWith("_") }) {
            $value = $attr.Value
            $value = Get-DecryptedString -Node $node -AttributName ("_encrypted-" + $attr.Name) -Value $value
            
            $target.SetAttribute($attr.Name, $value)
        }

        if ($node.InnerXml -or ($target.NodeType -eq [System.Xml.XmlNodeType]::Attribute)) {
            $value = $node.InnerXml
            $value = Get-DecryptedString -Node $node -AttributName "_encrypted" -Value $value

            $target.InnerXml = $value
        }
    }
}

$inputXml.Save($OutputFile)
