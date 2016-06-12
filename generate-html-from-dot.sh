#!/bin/bash
#
# Generates html page in current directory with graphs from .dot files in specified directory
# To visualize .dot files it uses https://github.com/mdaines/viz.js, all.dot file is ignored
# 
# Rostislav Svoboda rsvoboda@redhat.com
#

if [ $# -ne 1 ]; then
  echo "I require one argument, usage: $0 DOT_FILES_DIRECTORY"; exit 1
fi

DOT_FILES_DIRECTORY=$1
HTML_FILE=graph.html

echo '<!DOCTYPE html><html><head><meta charset="utf-8"><title>Tiny example</title></head>' > $HTML_FILE
echo '<body><script src="http://github.com/mdaines/viz.js/releases/download/v1.3.0/viz.js"></script><script>' >> $HTML_FILE

for i in `ls $DOT_FILES_DIRECTORY/*.dot | grep -v all.dot | sort`; do
  echo "document.body.innerHTML += \"<h3>$i</h3>\"" >> $HTML_FILE
  echo "document.body.innerHTML += Viz(" >> $HTML_FILE
  sed "s/^/'/g" $i | sed "s/$/' +/g" >> $HTML_FILE
  echo "'', { engine: \"dot\" });"  >> $HTML_FILE
done

echo '</script></body></html>' >> $HTML_FILE
echo "$HTML_FILE generated"
