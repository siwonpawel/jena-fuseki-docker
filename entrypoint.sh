#!/bin/sh
## Licensed under the terms of http://www.apache.org/licenses/LICENSE-2.0

## Check Java availability
if [ -z "$JAVA" ]
then
    if [ -z "$JAVA_HOME" ]
    then
       JAVA=$(which java)
    else
        JAVA=$JAVA_HOME/bin/java
    fi
fi

if [ -z "$JAVA" ]
then
    (
	echo "Cannot find a Java JDK."
	echo "Please set either set JAVA or JAVA_HOME and put java in your PATH."
    ) 1>&2
  exit 1
fi

# Check FUSEKI_HOME

JAR1="$FUSEKI_DIR/fuseki-server.jar"
JAR2="$FUSEKI_DIR/jena-fuseki-server-*.jar"
JAR=""

for J in "$JAR1" "$JAR2"
do
    # Expand
    J="$(echo $J)"
    if [ -e "$J" ]
    then
	JAR="$J"
	break
    fi
done

if [ "$JAR" = "" ]
then
    echo "Can't find jarfile to run"
    exit 1
fi

CP=$JAR
if [ -d "$FUSEKI_DIR/extra" ]
then
   CP="${CP}:${FUSEKI_DIR}/extra/*" 
fi

## Fuseki server. Default: serverui
MAIN="${MAIN:-serverui}"

## Translate names into Java entry points.
case $MAIN in
    ## Minimal server - no additional features.
    "basic")
	MAIN='org.apache.jena.fuseki.main.cmds.FusekiBasicCmd'
	;;
    ## Server, no UI, no admin work area, only Prometheus and Shiro
    "main")
	MAIN='org.apache.jena.fuseki.main.cmds.FusekiMainCmd'
	;;
    ## Plain server, with Fuseki modules, no UI, no admin work area, with Prometheus and Shiro.
    "server-plain" | "plain")
	MAIN='org.apache.jena.fuseki.main.cmds.FusekiServerPlainCmd'
	;;
    ## Full server, with Fuseki modules, with UI and with an admin work area.
    "serverui"| "server-ui" | "serverUI" )
	MAIN='org.apache.jena.fuseki.main.cmds.FusekiServerUICmd'
	;;
esac

## env | sort
echo XD exec "$JAVA" $JVM_ARGS -cp "$CP" "$MAIN" "$@"
exec "$JAVA" $JVM_ARGS -cp "$CP" "$MAIN" "$@"
