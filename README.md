# iris swagger converter client

This is an ObjectScript client for [swagger converter tools](https://converter.swagger.io/).  


## Description

This is a client only,  there is no conversion logic in this library.  
It uses [converter.swagger.io](https://converter.swagger.io/), see [GitHub repository](https://github.com/swagger-api/swagger-converter).  

This library allows to : 

 * Make conversion swagger v1.x, v2.x to OpenAPI 3.
 * Use by default the public REST service [converter.swagger.io](https://converter.swagger.io/).  
 * Use a local converter instance if you have one.  

## Installation

Terminal IRIS
```
zpm "install swagger-converter-cli"
```

## Usage

Example using an URL :  

```ObjectScript
    Set webConverter = ##class(dc.swaggerconverter.WebConverter).%New()
    Set sc = webConverter.ConvertByURL("https://petstore.swagger.io/v2/swagger.json", .OpenAPIV3)
    If ''sc Do ##class(%JSON.Formatter).%New().Format(OpenAPIV3)
```


Example to convert from a file:

```ObjectScript
    Set webConverter = ##class(dc.swaggerconverter.WebConverter).%New()
    Set sc = webConverter.ConvertFromFile("/home/irisowner/irisdev/spec.json", .OpenAPIV3)
    If ''sc Do ##class(%JSON.Formatter).%New().Format(OpenAPIV3)
```

Another example from a file : 

```ObjectScript
    Set webConverter = ##class(dc.swaggerconverter.WebConverter).%New()
    Set webConverter.specification = ##class(dc.swaggerconverter.WebConverter).fileToDynamic("/home/irisowner/irisdev/spec.json")
    Set sc = webConverter.Convert(.OpenAPIV3)
    If ''sc Do ##class(%JSON.Formatter).%New().Format(OpenAPIV3)
```

If you prefer use your own swagger converter instance, set these nodes with your configuration : 

```ObjectScript
    Set ^swaggerconverter("ConverterURL") = "https://converter.swagger.io"
    Set ^swaggerconverter("Port") = "443"
    Set ^swaggerconverter("SSLConfig") = "default"
```


## Docker Installation 

Clone/git pull the repo into any local directory

```
$ git clone https://github.com/lscalese/iris-swagger-converter-cli
```

Open the terminal in this directory and call the command to build and run InterSystems IRIS in container:

```
$ docker-compose up -d
```

If you have an error: 

```
iris_1  | terminate called after throwing an instance of 'std::runtime_error'
iris_1  |   what():  Unable to find/open file iris-main.log in current directory /home/irisowner/irisdev
```

It's probleme with right to create the iris-main.log file in the current directory.  

Try:
```
touch iris-main.log
chmod 777 iris-main.log
```


To open IRIS Terminal do:

```
$ docker-compose exec iris iris session iris -U IRISAPP
IRISAPP>zpm "install swagger-converter-cli"
```

To exit the terminal, do any of the following:

```
Enter HALT or H (not case-sensitive)
```