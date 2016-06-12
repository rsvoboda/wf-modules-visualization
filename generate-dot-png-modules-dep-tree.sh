#!/bin/bash
#
# Searches for module.xml and generates .dot files with module dependencies
# PNG files are generated using dot command from Graphviz  
# You can generate use custom sub-directory of root modules directory to limit all the generated dependencies
# 
# Rostislav Svoboda rsvoboda@redhat.com
#

if [ $# -ne 1 ]; then
  echo "I require one argument, usage: $0 JBOSS_MODULES_DIRECTORY"; exit 1
fi

type dot >/dev/null 2>&1 || { echo >&2 "I require dot from Graphviz but it's not installed.  Aborting."; exit 1; }
type xmlstarlet >/dev/null 2>&1 || { echo >&2 "I require xmlstarlet but it's not installed.  Aborting."; exit 1; }

JBOSS_MODULES_DIRECTORY=$1

echo "digraph {" > all.dot

for MODULE_XML_PATH in `find $JBOSS_MODULES_DIRECTORY | grep module.xml`; do

   echo "Processing $MODULE_XML_PATH"

   NAMESPACE=`grep "xmlns=" $MODULE_XML_PATH | sed "s/.*xmlns=\"\(.*1\..\).*/\1/"`  ## e.g. urn:jboss:module:1.3
   MODULE_NAME=$(xmlstarlet sel -N p=$NAMESPACE -t -v /p:module/@name $MODULE_XML_PATH)
   DEPENDENCIES=$(xmlstarlet sel -N p=$NAMESPACE -t -v /p:module/p:dependencies/p:module/@name $MODULE_XML_PATH)

   if [ -z "$DEPENDENCIES" ]; then
      echo "   Skipping as dependencies are empty"
   else
      echo "digraph {" > $MODULE_NAME.dot
      for i in $DEPENDENCIES; do 
         echo "\"$MODULE_NAME\" -> \"$i\"" | tee -a all.dot >> $MODULE_NAME.dot
      done
      echo "}" >> $MODULE_NAME.dot

      dot -Tpng $MODULE_NAME.dot > $MODULE_NAME.png
   fi
done

echo "}" >> all.dot
echo ""
echo "NOT generating PNG for ALL dependencies, it usually takes a lot of time and machine resources."
echo "If you still want it, just type following command: dot -Tpng all.dot > all.png"

