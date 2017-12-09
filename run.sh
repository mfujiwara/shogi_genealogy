#!/bin/sh

export PLANTUML_LIMIT_SIZE=32768
if [ ! -e lib ]; then
  mkdir lib
  wget http://sourceforge.net/projects/plantuml/files/plantuml.jar/download -O lib/plantuml.jar -q
fi
rm -rf out
mkdir out
echo "@startuml" > out/genealogy.pu
ruby shogi_genealogy.rb >> out/genealogy.pu
echo "@enduml" >> out/genealogy.pu

java -Dfile.encoding=UTF-8 -jar ./lib/plantuml.jar ./out/genealogy.pu
open -a Preview out/genealogy.png
