/// usage Example :
/// Set webConverter = ##class(dc.swaggerconverter.WebConverter).%New() <br/>
/// Set fileSpec = ##class(%Stream.FileCharacter).%New()<br/>
/// Do fileSpec.LinkToFile("/home/irisowner/irisdev/spec.json")<br/>
/// Set webConverter.specification = {}.%FromJSON(.fileSpec)<br/>
/// Set sc = webConverter.Convert(.OpenAPIV3)
/// If $$$ISOK(sc) Do OpenAPIV3.%ToJSON()
Class dc.swaggerconverter.WebConverter Extends (dc.swaggerconverter.Converter, %RegisteredObject)
{

Parameter DEFAULTCONVERTER = "https://converter.swagger.io";

Parameter SSLCONFIGURATION = "default";

Property ConverterURL As %String [ InitialExpression = {$Get(^swaggerconverter("ConverterURL"), ..#DEFAULTCONVERTER)} ];

Property SSLConfig As %String [ InitialExpression = {$Get(^swaggerconverter("SSLConfig"), ..#SSLCONFIGURATION)} ];

Property Port As %Integer [ InitialExpression = {$Get(^swaggerconverter("Port"))} ];

Property httpRequest As %Net.HttpRequest;

/// Set sc = ##class(dc.swaggerconverter.WebConverter).test()
ClassMethod test() As %Status
{
    Set webConverter = ##class(dc.swaggerconverter.WebConverter).%New()
    Set webConverter.specification = ##class(dc.swaggerconverter.WebConverter).fileToDynamic("/home/irisowner/irisdev/spec.json")
    ;Set sc = webConverter.Convert(.OpenAPIV3)
    Set url = "https://petstore.swagger.io/v2/swagger.json"
     Set sc = webConverter.ConvertByURL(url, .OpenAPIV3)
    If $$$ISOK(sc) Do OpenAPIV3.%ToJSON()
    Quit sc
}

Method Convert(Output OpenAPIV3 As %DynamicObject) As %Status
{
    Set OpenAPIV3 = {}, sc = $$$OK
    Do:'$ISOBJECT(..httpRequest) ..initHttpRequestObject()

	Set ..httpRequest.ContentType = "application/json"
    Do ..specification.%ToJSON(..httpRequest.EntityBody)
	$$$QuitOnError(..httpRequest.Send("POST", "/api/convert"))

    #dim pHttpResponse As %Net.HttpResponse = ..httpRequest.HttpResponse
	
    Quit:pHttpResponse.StatusCode'="200" $$$ERROR(5001, "Https Status code "_pHttpResponse.StatusCode)

    Set OpenAPIV3 = {}.%FromJSON(pHttpResponse.Data)
    
    Quit sc
}

Method ConvertFromFile(path As %String, Output OpenAPIV3 As %DynamicObject) As %Status
{
    Set ..specification = ##class(dc.swaggerconverter.WebConverter).fileToDynamic(path)
    Quit ..Convert(.OpenAPIV3)
}

Method ConvertByURL(URL As %String, Output OpenAPIV3 As %DynamicObject) As %Status
{

    Set OpenAPIV3 = {}, sc = $$$OK
    Do:'$ISOBJECT(..httpRequest) ..initHttpRequestObject()

	Do ..httpRequest.SetParam("url", URL)

	$$$QuitOnError(..httpRequest.Send("GET", "/api/convert"))

    #dim pHttpResponse As %Net.HttpResponse = ..httpRequest.HttpResponse
	
    Quit:pHttpResponse.StatusCode'="200" $$$ERROR(5001, "Https Status code "_pHttpResponse.StatusCode)

    Set OpenAPIV3 = {}.%FromJSON(pHttpResponse.Data)
    
    Return sc
}

Method initHttpRequestObject()
{
    Set ..httpRequest = ##class(%Net.HttpRequest).%New()
    Set ..httpRequest.Server = $Piece(..ConverterURL, "://", 2)

	If ..ConverterURL [ "https:" {
        Do ..AddSSLConfig(..SSLConfig)
        Set ..httpRequest.Https = $$$YES
        Set ..httpRequest.SSLConfiguration = ..SSLConfig
    }

    Set:..Port'="" ..httpRequest.Port = ..Port

    
	Set ..httpRequest.ContentType = "application/json"
    Do ..httpRequest.SetHeader("accept", "application/json")

    Quit
}

ClassMethod fileToDynamic(path As %String) As %DynamicObject
{
    Set sc = $$$OK
    Set fileSpec = ##class(%Stream.FileCharacter).%New()
    $$$ThrowOnError(fileSpec.LinkToFile(path))
    Quit {}.%FromJSON(.fileSpec)
}

ClassMethod AddSSLConfig(name As %String)
{
    New $NAMESPACE
    set $namespace="%SYS" do:'##class(Security.SSLConfigs).Exists(name) ##class(Security.SSLConfigs).Create(name)
    Quit
}

}
