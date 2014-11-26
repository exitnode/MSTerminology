#!/bin/bash
# This script translates terminologies used in MS products by sending a SOAP
# request to api.terminology.microsoft.com/terminology and extracting the result
# MS Language Portal: http://www.microsoft.com/Language/en-US/Search.aspx
# WSDL: http://api.terminology.microsoft.com/Terminology.svc?singleWsdl
# More info: http://www.microsoft.com/Language/de-de/Microsoft-Terminology-API.aspx
#
# Copyright (C) 2014 Michael Clemens
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program. 
# If not, see http://www.gnu.org/licenses/.#
#
# usage: ./MSTerminology "STRING TO BE TRANSLATED"

text=$1

from="en-us"
to="de-de"
product="Windows"
version="7"

xml="<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:ter=\"http://api.terminology.microsoft.com/terminology\"> \
   <soapenv:Header/> \
   <soapenv:Body> \
      <ter:GetTranslations> \
         <ter:text>${text}</ter:text> \
         <ter:from>${from}</ter:from> \
         <ter:to>${to}</ter:to> \
         <ter:searchOperator>Contains</ter:searchOperator> \
         <ter:sources> \
            <ter:TranslationSource>UiStrings</ter:TranslationSource> \
         </ter:sources> \
         <ter:unique>false</ter:unique> \
         <ter:maxTranslations>1</ter:maxTranslations> \
         <ter:includeDefinitions>true</ter:includeDefinitions> \
         <ter:products> \
            <ter:Product> \
               <ter:Name>${product}</ter:Name> \
               <ter:Versions> \
                  <ter:Version> \
                     <ter:Name>${version}</ter:Name> \
                  </ter:Version> \
               </ter:Versions> \
            </ter:Product> \
         </ter:products> \
      </ter:GetTranslations> \
   </soapenv:Body> \
</soapenv:Envelope>"

output=$(curl -s -H "Content-Type: text/xml; charset=utf-8" -H "SOAPAction: \"http://api.terminology.microsoft.com/terminology/Terminology/GetTranslations\"" -d "${xml}" -X POST http://api.terminology.microsoft.com/Terminology.svc)

result=$(echo ${output} | sed -e 's,.*<TranslatedText>\([^<]*\)</TranslatedText>.*,\1,g')

if [[ $result != *s:Envelope* ]]; then
	echo $result
else
	echo "'"$text"' could not be translated. The server's response was:"
	echo $output
fi
