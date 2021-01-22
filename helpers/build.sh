#!/bin/sh
set -efux

version=30.9.0
apk="../hapoalim-${version}.apk"
tempdir="../hapoalim-${version}.apk-decompiled"

rm -rf "${tempdir}"
java -Xmx256m -jar apktool_2.4.1.jar d -o "${tempdir}" "${apk}"

cp -r "../patch/${version}/assets" \
      "../patch/${version}/res" \
      "../patch/${version}/smali_classes2" \
      "../patch/${version}/AndroidManifest.xml" \
      "${tempdir}"

ag "com\.ideomobile\.hapoalim" -l -r "${tempdir}" | tr -d '\r' | sort | uniq | xargs -P 8 -I {} sed -i'' -b 's,com\.ideomobile\.hapoalim,com\.ideomobile\.hapoalimalt,g' {}
ag "Lcom/ideomobile/hapoalim"  -l -r "${tempdir}" | tr -d '\r' | sort | uniq | xargs -P 8 -I {} sed -i'' -b 's,Lcom/ideomobile/hapoalim,Lcom/ideomobile/hapoalimalt,g' {}

java -Xmx256m -jar apktool_2.4.1.jar b "${tempdir}"

keystore=debug.keystore

[ -e "${keystore}" ] || \
  keytool -genkey -keystore "${keystore}" -keyalg RSA -keysize 2048 \
          -validity 10000 -alias "${alias}" \
          -dname "cn=Unknown, ou=Unknown, o=Unknown, c=Unknown" \
          -storepass "${storepass}" -keypass "${keypass}"

java -Xmx256m -jar uber-apk-signer-1.1.0.jar \
              --ksDebug "${keystore}" \
              -a "${tempdir}/dist/hapoalim-${version}.apk" \
              --allowResign \
              --overwrite
