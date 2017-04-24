# Configuration Transformation

The proposed solution to transform the configuration files requires a [special script](Transform.ps1) to be used. This includes several features, like:

 * Separating the whole transformation into multiple files, some of which may have definitions of parameters, and others have the actual values;
 * Encryption of sensitive values with or without a key in order to make sure that the data kept in 3rd party sources will never leak.

The definition of transformation is a plain XML file. The basic idea is simple: the engineer may specify the XPath to an element or attribute, and then:

 * Specify attributes and/or inner text (or nested XML) for the elements;
 * Specify value for the single attribute, if XPath makes its way to an attribute.

## Transformation Definition

Below is an abstract definition of a transformation XML file:

```xml
<data>
    <values>
    	<_parameter _xpath="//configuration/TempStorage" location="c:\temp" maxFiles="100" />
        <_parameter _xpath="//configuration/database/@connectionString">mongodb://127.0.0.1:2500</_parameter>
    </values>
</data>
```

Quite simple, right? Once we've got the transformation definition, we can proceed to transformation itself:

```
powershell ".\transform.ps1" -InputFile ".\Template\Web.config" -OutputFile ".\Web.config" -Script ".\Web.config.transform.xml"
```

After the command has been run, the script will go through each of the `values` elements, finding all of the items in template document by `_xpath` value (in this particular case the template file is .\Template\Web.config), and do the following:

 * If XPath points out an element, all attributes, which present in the value element, are copied into corresponding element in template. If inner text or inner XML is not empty in the value element, it is copied to the template, thus replacing the inner text it template element;
 * If XPath point out an attribute, the inner text of the value element is copied to that attribute in template. Such value definitions cannot have attributes.

There is one exception in the rules above. Any attribute that starts from an underscore character, is considered as reserved, so it never copied to the template document, and such attributes may exist in definitions of attributes. This is also applicable for element names: any element, which name starts from an underscore, is a reserved element. This way we consider `_parameter` element reserved: it has a special meaning, which will be explained further.

There is also an obvious rule related to the elements within `values` section: all of these elements must have an `_xpath` attribute. If at least one element doesn't have that — an error will be thrown by the script.

But isn't that too simple? One can hardly navigate through all these values, since these XPaths draw attention from the values, the parameters got no names that may describe the actual meaning of the parameter, and overall this is barely maintainable. So let's introduce one change:

```xml
<data>
	<nodes>
    	<_parameter _name="temp-storage" _xpath="//configuration/TempStorage" />
        <_parameter _name="connection-string" _xpath="//configuration/database/@connectionString" />
    </nodes>
    <values>
    	<temp-storage location="c:\temp" maxFiles="100" />
        <connection-string>mongodb://127.0.0.1:2500</connection-string>
    </values>
</data>
```

We've got a simple, but useful change here: all these XPaths are brought into a separate section. What now the script does is finds the node element by a value element name (see that `_name` attribute for nodes), and then merges these two elements together. No complicated logic, or cheatery, or something: just a simple merge, which results the value element having everything that the corresponding node element had, including the reserved attributes. Just one rule: the value element attributes and inner text has priority over attributes and inner text of the node element.

So, now what does the `_parameter` element name actually mean: if we've got an element with such a name, the script won't search a node with corresponding `_name`: it just considers this as a complete definition of parameter. But other element names need to be resolved: say, if we've got a `temp-storage` value, but couldn't find a node with that `_name` — an error will occur.

So far so good: the values section is now free of these XPaths, but the definition of parameter is still here, in the file. Why not to let us reuse them in the transformation definitions for different environments? What we're going to do now is to bring the `nodes` section into a separate file:

**Parameters.xml:**
```xml
<data>
	<nodes>
    	<_parameter _name="temp-storage" _xpath="//configuration/TempStorage" />
        <_parameter _name="connection-string" _xpath="//configuration/database/@connectionString" />
    </nodes>
</data>
```

**Web.config.transform.xml:**
```xml
<data>
	<include path="Parameters.xml" />
    <values>
    	<temp-storage location="c:\temp" maxFiles="100" />
        <connection-string>mongodb://127.0.0.1:2500</connection-string>
    </values>
</data>
```

No more `nodes` section in the transformation file: everything is brought to separate XML. The rule is the same: every value element is merged with the node element. But there's one more feature. We may do the following:

**Web.config.transform.xml:**
```xml
<data>
	<include path="Parameters.xml" />
    <node>
    	<temp-storage _name="simple-temp-storage" maxFiles="100" />
    	<temp-storage _name="large-temp-storage" maxFiles="1000" />
    </node>
    <values>
    	<large-temp-storage location="d:\temp" />
        <connection-string>mongodb://127.0.0.1:2500</connection-string>
    </values>
</data>
```

See what: the nodes may also be merged with other nodes. And we've got a cool feature: just replace `large-temp-storage` with `simple-temp-storage` — and the configuration will be replaced with predefined for the simple temp storage.

The number of includes or the depth of inclusion are not limited.

## Special Features

### Elements and Attributes Manipulations

The description above gives an impression, that the script may only add or modify attributes and inner text or XML of elements. However, there's a special syntax that lets to append nodes without replacing the whole content of the element, and also remove elements and attributes.

#### Appending a new element

There may be the cases, when an engineer can't be confident whether an element, lets call it `A`, contains an another element, `B`. If we use the regular syntax provided above to create the element `B`, we may only replace the whole content of the `A`, so the previous content is going to be lost. To make the changes over the elements more accurate, there was introduced a special syntax, that lets to create a specific element by XPath of the parent element and the name of that element. If a child element already presents within the element, nothing happens: we just make our changes over an existing element then. The syntax follows:

```xml
<_parameter _name="http-protocol" _xpath="//configuration/system.webServer" _create-or-update="httpProtocol" />
```

This way we don't touch an existing content of `system.webServer` element, but just make sure, that this element contains `httpProtocol` element. Any non-reserved attributes are going to be copied to `httpProtocol` element. Please be aware, that if the script finds multiple `httpProtocol` elements as children of `system.webServer` — an error will be thrown.

#### Removing nodes and elements

The template document may contain the attributes or elements that not supposed to be in a resulting XML document. What we going to do in this case is to use the special syntax:

```xml
<_parameter _name="disable-compilation-debug" _xpath="//configuration/system.web/compilation/@debug" _remove="true" />
```

OK, we could just set this one to `false`, but who would keep himself from testing a new cool feature of the transformation script, eh? So the `_remove` attribute is to remove anything pointed out by the XPath. And just for the case if you want to remove the attribute by its name:

```xml
<_parameter _name="disable-compilation-debug" _xpath="//configuration/system.web/compilation/" _remove-debug="true" />
```

### Encryption

Source control is a perfect place for storing the transformations. However, the values may include some sensitive data, which is preferable to keep in a secret, like connection strings, which include passwords, or the encryption keys. The obvious solution to keep them secure is to encrypt the values before they're specified in the transformation file. When we get to transform the file, we just decrypt these values. That's simple: the key to decrypt the data must be kept on CI server, inaccessible for attackers.

The script provides an ability to decrypt the data during transformation. This is done using the regular `CovertFrom-SecureString` command, which does precisely the following:

 * If we specify the key, it uses AES algorithm to encrypt the data. In that case the command (hence the script, too) requires 128, 192 or 256-bit key as a parameter. This key may be provided as a `-Passkey` parameter of the script in a base64 format.
 * If the key is omitted, the command uses Windows Data Protection API to encrypt the data. This means, that the encrypted data will forever be bound to specific Windows account, that runs the CI.

The following is the command that lets to create the actual encrypted data:

```
ConvertTo-SecureString "mongodb://127.0.0.1:2500" -AsPlainText -Force | ConvertFrom-SecureString | Clip
```

It uses the Windows Data Protection API to encrypt the provided string, so it must be run from the same account, that runs the CI. The result is copied in Windows Clipboard and in my case represented by the following string:

```
01000000d08c9ddf0115d1118c7a00c04fc297eb01000000da09e9b3fea2c847889c5fab7f0a4e6100000000020000000000106600000001000020000000233aef1ea6049b4655b6aaee82896def0be4cd0fed9eeeb2504b4001bb010b78000000000e8000000002000020000000f7a5d02b743c732df70af33c9cd639a5f12bc6c9038b18e3e22bb79aedba3d4140000000b931d8e2dcba9114798c2a043c46d7ef320ad23edd48f99f68f101b7c6755b048331344d263e929d6ca666bd6fb9528e9331906b78f1dc366bcf0e8eeba1f577400000008f79d047ba259eefba5e6098e7491e39473249b7506245d024c62cb49a386f8613efb648243f138bd06f198a0effb2b7dadbb80418b0bbe3a1f49341bbd79ae7
```

So the transformation will be represented the following way:

```xml
<connection-string _encrypted="true">01000...d79ae7</connection-string>
```

See this `_encrypted` attribute? It tells the script that the content of the transformation value is encrypted. Not only inner text or inner XML may be encrypted: the attributes can be too. In this case everything is the same, except the name of attribute: it must be `_encrypted-name` where `name` is the name of attribute, which value is encrypted.

## Agreements

 * Names of the nodes must consist only of lower case letters, numbers and dashes to separate words.