# date.pl -- date/time gateway
#
# $Id: date.pl,v 2.9 1995/10/05 06:12:42 sanders Exp $
#
# Tony Sanders <sanders@earth.com>, April 1993
#
# This is setup to work with 4.4BSD-style zoneinfo files.

package date;

sub main'do_date {
    local($timezone) = @_;
    local($tz) = $tzdir . "/" . ($timezone || "GMT");
    &main'error('bad_request', "Invalid Timezone: $timezone")
        unless ((-f $tz) && ($timezone !~ m,[^A-Za-z0-9_/+~-],));

    local($TZ) = $main'ENV{'TZ'};       # save and restore timezone
    $main'ENV{'TZ'} = $tz;

    local($date);
    chop($date = `$cmd`);

    &main'MIME_header('ok', 'text/html');
    print "<HEAD>\n<TITLE>Date and Time Gateway</TITLE>\n</HEAD>\n";
    print "<BODY>\n";
    print "<H1><IMG SRC=\"/icons/misc/datetime.gif\"> Date and Time Gateway</H1>\n";
    print "<H2>", ($timezone || "GMT"), "</H1>\n";
    print "<H2>$date</H2>\n";
    print "<H3>Available Timezones</H3>\n";
    print '
<H4>Greenwich Mean Time (GMT/UCT/UTC/Universal/Zulu)</H4>

<A HREF="/date?Etc/GMT+12">+12</A>
<A HREF="/date?Etc/GMT+11">+11</A>
<A HREF="/date?Etc/GMT+10">+10</A>
<A HREF="/date?Etc/GMT+9">+9</A>
<A HREF="/date?Etc/GMT+8">+8</A>
<A HREF="/date?Etc/GMT+7">+7</A>
<A HREF="/date?Etc/GMT+6">+6</A>
<A HREF="/date?Etc/GMT+5">+5</A>
<A HREF="/date?Etc/GMT+4">+4</A>
<A HREF="/date?Etc/GMT+3">+3</A>
<A HREF="/date?Etc/GMT+2">+2</A>
<A HREF="/date?Etc/GMT+1">+1</A>
<A HREF="/date?Etc/GMT">GMT</A>
<A HREF="/date?Etc/GMT-1">-1</A>
<A HREF="/date?Etc/GMT-2">-2</A>
<A HREF="/date?Etc/GMT-3">-3</A>
<A HREF="/date?Etc/GMT-4">-4</A>
<A HREF="/date?Etc/GMT-5">-5</A>
<A HREF="/date?Etc/GMT-6">-6</A>
<A HREF="/date?Etc/GMT-7">-7</A>
<A HREF="/date?Etc/GMT-8">-8</A>
<A HREF="/date?Etc/GMT-9">-9</A>
<A HREF="/date?Etc/GMT-10">-10</A>
<A HREF="/date?Etc/GMT-11">-11</A>
<A HREF="/date?Etc/GMT-12">-12</A>
<A HREF="/date?Etc/GMT-13">-13</A>

<!-- Start of output from date-process-zoneinfo.pl -->

<H4>Africa</H4>
<PRE>
<A HREF="/date?Africa/Abidjan">Abidjan</A>                   <A HREF="/date?Africa/Djibouti">Djibouti</A>                  <A HREF="/date?Africa/Maputo">Maputo</A>
<A HREF="/date?Africa/Accra">Accra</A>                     <A HREF="/date?Africa/Douala">Douala</A>                    <A HREF="/date?Africa/Maseru">Maseru</A>
<A HREF="/date?Africa/Addis_Ababa">Addis_Ababa</A>               <A HREF="/date?Africa/Freetown">Freetown</A>                  <A HREF="/date?Africa/Mbabane">Mbabane</A>
<A HREF="/date?Africa/Algiers">Algiers</A>                   <A HREF="/date?Africa/Gaborone">Gaborone</A>                  <A HREF="/date?Africa/Mogadishu">Mogadishu</A>
<A HREF="/date?Africa/Asmera">Asmera</A>                    <A HREF="/date?Africa/Harare">Harare</A>                    <A HREF="/date?Africa/Monrovia">Monrovia</A>
<A HREF="/date?Africa/Bamako">Bamako</A>                    <A HREF="/date?Africa/Johannesburg">Johannesburg</A>              <A HREF="/date?Africa/Nairobi">Nairobi</A>
<A HREF="/date?Africa/Bangui">Bangui</A>                    <A HREF="/date?Africa/Kampala">Kampala</A>                   <A HREF="/date?Africa/Ndjamena">Ndjamena</A>
<A HREF="/date?Africa/Banjul">Banjul</A>                    <A HREF="/date?Africa/Khartoum">Khartoum</A>                  <A HREF="/date?Africa/Niamey">Niamey</A>
<A HREF="/date?Africa/Bissau">Bissau</A>                    <A HREF="/date?Africa/Kigali">Kigali</A>                    <A HREF="/date?Africa/Nouakchott">Nouakchott</A>
<A HREF="/date?Africa/Blantyre">Blantyre</A>                  <A HREF="/date?Africa/Kinshasa">Kinshasa</A>                  <A HREF="/date?Africa/Ouagadougou">Ouagadougou</A>
<A HREF="/date?Africa/Brazzaville">Brazzaville</A>               <A HREF="/date?Africa/Lagos">Lagos</A>                     <A HREF="/date?Africa/Porto-Novo">Porto-Novo</A>
<A HREF="/date?Africa/Bujumbura">Bujumbura</A>                 <A HREF="/date?Africa/Libreville">Libreville</A>                <A HREF="/date?Africa/Sao_Tome">Sao_Tome</A>
<A HREF="/date?Africa/Cairo">Cairo/Egypt</A>               <A HREF="/date?Africa/Lome">Lome</A>                      <A HREF="/date?Africa/Timbuktu">Timbuktu</A>
<A HREF="/date?Africa/Casablanca">Casablanca</A>                <A HREF="/date?Africa/Luanda">Luanda</A>                    <A HREF="/date?Africa/Tripoli">Tripoli/Libya</A>
<A HREF="/date?Africa/Conakry">Conakry</A>                   <A HREF="/date?Africa/Lumumbashi">Lumumbashi</A>                <A HREF="/date?Africa/Tunis">Tunis</A>
<A HREF="/date?Africa/Dakar">Dakar</A>                     <A HREF="/date?Africa/Lusaka">Lusaka</A>                    <A HREF="/date?Africa/Windhoek">Windhoek</A>
<A HREF="/date?Africa/Dar_es_Salaam">Dar_es_Salaam</A>             <A HREF="/date?Africa/Malabo">Malabo</A>                    <A HREF="/date?"></A>
</PRE>
<H4>America</H4>
<PRE>
<A HREF="/date?America/Anchorage">Anchorage</A>                              <A HREF="/date?America/Managua">Managua</A>
<A HREF="/date?America/Anguilla">Anguilla</A>                               <A HREF="/date?America/Manaus">Manaus</A>
<A HREF="/date?America/Antigua">Antigua</A>                                <A HREF="/date?America/Martinique">Martinique</A>
<A HREF="/date?America/Asuncion">Asuncion</A>                               <A HREF="/date?America/Mazatlan">Mazatlan</A>
<A HREF="/date?America/Atka">Atka</A>                                   <A HREF="/date?America/Mexico_City">Mexico_City</A>
<A HREF="/date?America/Barbados">Barbados</A>                               <A HREF="/date?America/Miquelon">Miquelon</A>
<A HREF="/date?America/Belize">Belize</A>                                 <A HREF="/date?America/Montevideo">Montevideo</A>
<A HREF="/date?America/Bogota">Bogota</A>                                 <A HREF="/date?America/Montreal">Montreal</A>
<A HREF="/date?America/Buenos_Aires">Buenos_Aires</A>                           <A HREF="/date?America/Montserrat">Montserrat</A>
<A HREF="/date?America/Caracas">Caracas</A>                                <A HREF="/date?America/Nassau">Nassau</A>
<A HREF="/date?America/Cayenne">Cayenne</A>                                <A HREF="/date?America/New_York">New_York/EST5EDT</A>
<A HREF="/date?America/Cayman">Cayman</A>                                 <A HREF="/date?America/Noronha">Noronha</A>
<A HREF="/date?America/Chicago">Chicago/CST6CDT</A>                        <A HREF="/date?America/Panama">Panama</A>
<A HREF="/date?America/Costa_Rica">Costa_Rica</A>                             <A HREF="/date?America/Paramaribo">Paramaribo</A>
<A HREF="/date?America/Curacao">Curacao</A>                                <A HREF="/date?America/Phoenix">Phoenix/MST</A>
<A HREF="/date?America/Denver">Denver/MST7MDT/Navajo</A>                  <A HREF="/date?America/Port-au-Prince">Port-au-Prince</A>
<A HREF="/date?America/Detroit">Detroit</A>                                <A HREF="/date?America/Port_of_Spain">Port_of_Spain</A>
<A HREF="/date?America/Dominica">Dominica</A>                               <A HREF="/date?America/Porto_Acre">Porto_Acre</A>
<A HREF="/date?America/Edmonton">Edmonton</A>                               <A HREF="/date?America/Puerto_Rico">Puerto_Rico</A>
<A HREF="/date?America/El_Salvador">El_Salvador</A>                            <A HREF="/date?America/Regina">Regina</A>
<A HREF="/date?America/Ensenada">Ensenada</A>                               <A HREF="/date?America/Santiago">Santiago</A>
<A HREF="/date?America/Fort_Wayne">Fort_Wayne/EST</A>                         <A HREF="/date?America/Santo_Domingo">Santo_Domingo</A>
<A HREF="/date?America/Godthab">Godthab</A>                                <A HREF="/date?America/Sao_Paulo">Sao_Paulo</A>
<A HREF="/date?America/Grand_Turk">Grand_Turk</A>                             <A HREF="/date?America/Scoresbysund">Scoresbysund</A>
<A HREF="/date?America/Grenada">Grenada</A>                                <A HREF="/date?America/St_Johns">St_Johns</A>
<A HREF="/date?America/Guadeloupe">Guadeloupe</A>                             <A HREF="/date?America/St_Kitts">St_Kitts</A>
<A HREF="/date?America/Guatemala">Guatemala</A>                              <A HREF="/date?America/St_Lucia">St_Lucia</A>
<A HREF="/date?America/Guayaquil">Guayaquil</A>                              <A HREF="/date?America/St_Vincent">St_Vincent</A>
<A HREF="/date?America/Guyana">Guyana</A>                                 <A HREF="/date?America/Tegucigalpa">Tegucigalpa</A>
<A HREF="/date?America/Halifax">Halifax</A>                                <A HREF="/date?America/Thule">Thule</A>
<A HREF="/date?America/Havana">Havana/Cuba</A>                            <A HREF="/date?America/Tijuana">Tijuana</A>
<A HREF="/date?America/Jamaica">Jamaica/Jamaica</A>                        <A HREF="/date?America/Vancouver">Vancouver</A>
<A HREF="/date?America/Knox_IN">Knox_IN</A>                                <A HREF="/date?America/Virgin">Virgin</A>
<A HREF="/date?America/La_Paz">La_Paz</A>                                 <A HREF="/date?America/Whitehorse">Whitehorse</A>
<A HREF="/date?America/Lima">Lima</A>                                   <A HREF="/date?America/Winnipeg">Winnipeg</A>
<A HREF="/date?America/Los_Angeles">Los_Angeles/PST8PDT</A>                    <A HREF="/date?"></A>
</PRE>
<H4>Asia</H4>
<PRE>
<A HREF="/date?Asia/Aden">Aden</A>                      <A HREF="/date?Asia/Istanbul">Istanbul</A>                  <A HREF="/date?Asia/Saigon">Saigon</A>
<A HREF="/date?Asia/Alma-Ata">Alma-Ata</A>                  <A HREF="/date?Asia/Jakarta">Jakarta</A>                   <A HREF="/date?Asia/Seoul">Seoul/ROK</A>
<A HREF="/date?Asia/Amman">Amman</A>                     <A HREF="/date?Asia/Jayapura">Jayapura</A>                  <A HREF="/date?Asia/Shanghai">Shanghai/PRC</A>
<A HREF="/date?Asia/Anadyr">Anadyr</A>                    <A HREF="/date?Asia/Kabul">Kabul</A>                     <A HREF="/date?Asia/Singapore">Singapore/Singapore</A>
<A HREF="/date?Asia/Ashkhabad">Ashkhabad</A>                 <A HREF="/date?Asia/Kamchatka">Kamchatka</A>                 <A HREF="/date?Asia/Taipei">Taipei/ROC</A>
<A HREF="/date?Asia/Baghdad">Baghdad</A>                   <A HREF="/date?Asia/Karachi">Karachi</A>                   <A HREF="/date?Asia/Tashkent">Tashkent</A>
<A HREF="/date?Asia/Bahrain">Bahrain</A>                   <A HREF="/date?Asia/Katmandu">Katmandu</A>                  <A HREF="/date?Asia/Tbilisi">Tbilisi</A>
<A HREF="/date?Asia/Baku">Baku</A>                      <A HREF="/date?Asia/Kuala_Lumpur">Kuala_Lumpur</A>              <A HREF="/date?Asia/Tehran">Tehran/Iran</A>
<A HREF="/date?Asia/Bangkok">Bangkok</A>                   <A HREF="/date?Asia/Kuwait">Kuwait</A>                    <A HREF="/date?Asia/Tel_Aviv">Tel_Aviv/Israel</A>
<A HREF="/date?Asia/Beirut">Beirut</A>                    <A HREF="/date?Asia/Macao">Macao</A>                     <A HREF="/date?Asia/Thimbu">Thimbu</A>
<A HREF="/date?Asia/Bishkek">Bishkek</A>                   <A HREF="/date?Asia/Magadan">Magadan</A>                   <A HREF="/date?Asia/Tokyo">Tokyo/Japan</A>
<A HREF="/date?Asia/Brunei">Brunei</A>                    <A HREF="/date?Asia/Manila">Manila</A>                    <A HREF="/date?Asia/Tomsk">Tomsk</A>
<A HREF="/date?Asia/Calcutta">Calcutta</A>                  <A HREF="/date?Asia/Muscat">Muscat</A>                    <A HREF="/date?Asia/Ujung_Pandang">Ujung_Pandang</A>
<A HREF="/date?Asia/Colombo">Colombo</A>                   <A HREF="/date?Asia/Nicosia">Nicosia</A>                   <A HREF="/date?Asia/Ulan_Bator">Ulan_Bator</A>
<A HREF="/date?Asia/Dacca">Dacca</A>                     <A HREF="/date?Asia/Novosibirsk">Novosibirsk</A>               <A HREF="/date?Asia/Vientiane">Vientiane</A>
<A HREF="/date?Asia/Damascus">Damascus</A>                  <A HREF="/date?Asia/Omsk">Omsk</A>                      <A HREF="/date?Asia/Vladivostok">Vladivostok</A>
<A HREF="/date?Asia/Dubai">Dubai</A>                     <A HREF="/date?Asia/Phnom_Penh">Phnom_Penh</A>                <A HREF="/date?Asia/Yakutsk">Yakutsk</A>
<A HREF="/date?Asia/Dushanbe">Dushanbe</A>                  <A HREF="/date?Asia/Pyongyang">Pyongyang</A>                 <A HREF="/date?Asia/Yekaterinburg">Yekaterinburg</A>
<A HREF="/date?Asia/Gaza">Gaza</A>                      <A HREF="/date?Asia/Qatar">Qatar</A>                     <A HREF="/date?Asia/Yerevan">Yerevan</A>
<A HREF="/date?Asia/Hong_Kong">Hong_Kong/Hongkong</A>        <A HREF="/date?Asia/Rangoon">Rangoon</A>                   <A HREF="/date?"></A>
<A HREF="/date?Asia/Irkutsk">Irkutsk</A>                   <A HREF="/date?Asia/Riyadh">Riyadh</A>
</PRE>
<H4>Atlantic</H4>
<PRE>
<A HREF="/date?Atlantic/Azores">Azores</A>                    <A HREF="/date?Atlantic/Faeroe">Faeroe</A>                    <A HREF="/date?Atlantic/South_Georgia">South_Georgia</A>
<A HREF="/date?Atlantic/Bermuda">Bermuda</A>                   <A HREF="/date?Atlantic/Jan_Mayen">Jan_Mayen</A>                 <A HREF="/date?Atlantic/St_Helena">St_Helena</A>
<A HREF="/date?Atlantic/Canary">Canary</A>                    <A HREF="/date?Atlantic/Madeira">Madeira</A>                   <A HREF="/date?Atlantic/Stanley">Stanley</A>
<A HREF="/date?Atlantic/Cape_Verde">Cape_Verde</A>                <A HREF="/date?Atlantic/Reykjavik">Reykjavik/Iceland</A>         <A HREF="/date?"></A>
</PRE>
<H4>Australia</H4>
<PRE>
<A HREF="/date?Australia/ACT">ACT</A>                       <A HREF="/date?Australia/LHI">LHI</A>                       <A HREF="/date?Australia/South">South</A>
<A HREF="/date?Australia/Adelaide">Adelaide</A>                  <A HREF="/date?Australia/Lord_Howe">Lord_Howe</A>                 <A HREF="/date?Australia/Sydney">Sydney</A>
<A HREF="/date?Australia/Brisbane">Brisbane</A>                  <A HREF="/date?Australia/Melbourne">Melbourne</A>                 <A HREF="/date?Australia/Tasmania">Tasmania</A>
<A HREF="/date?Australia/Broken_Hill">Broken_Hill</A>               <A HREF="/date?Australia/NSW">NSW</A>                       <A HREF="/date?Australia/Victoria">Victoria</A>
<A HREF="/date?Australia/Canberra">Canberra</A>                  <A HREF="/date?Australia/North">North</A>                     <A HREF="/date?Australia/West">West</A>
<A HREF="/date?Australia/Darwin">Darwin</A>                    <A HREF="/date?Australia/Perth">Perth</A>                     <A HREF="/date?Australia/Yancowinna">Yancowinna</A>
<A HREF="/date?Australia/Hobart">Hobart</A>                    <A HREF="/date?Australia/Queensland">Queensland</A>                <A HREF="/date?"></A>
</PRE>
<H4>Brazil</H4>
<PRE>
<A HREF="/date?Brazil/Acre">Acre</A>                      <A HREF="/date?Brazil/East">East</A>                      <A HREF="/date?"></A>
<A HREF="/date?Brazil/DeNoronha">DeNoronha</A>                 <A HREF="/date?Brazil/West">West</A>
</PRE>
<H4>Canada</H4>
<PRE>
<A HREF="/date?Canada/Atlantic">Atlantic</A>                  <A HREF="/date?Canada/Mountain">Mountain</A>                  <A HREF="/date?Canada/Yukon">Yukon</A>
<A HREF="/date?Canada/Central">Central</A>                   <A HREF="/date?Canada/Newfoundland">Newfoundland</A>              <A HREF="/date?"></A>
<A HREF="/date?Canada/East-Saskatchewan">East-Saskatchewan</A>         <A HREF="/date?Canada/Pacific">Pacific</A>                   <A HREF="/date?"></A>
<A HREF="/date?Canada/Eastern">Eastern</A>
</PRE>
<H4>Chile</H4>
<PRE>
<A HREF="/date?Chile/Continental">Continental</A>               <A HREF="/date?Chile/EasterIsland">EasterIsland</A>              <A HREF="/date?"></A>
</PRE>
<H4>Europe</H4>
<PRE>
<A HREF="/date?Europe/Amsterdam">Amsterdam</A>                 <A HREF="/date?Europe/Kiev">Kiev</A>                      <A HREF="/date?Europe/Sarajevo">Sarajevo</A>
<A HREF="/date?Europe/Andorra">Andorra</A>                   <A HREF="/date?Europe/Kuybyshev">Kuybyshev</A>                 <A HREF="/date?Europe/Simferopol">Simferopol</A>
<A HREF="/date?Europe/Athens">Athens</A>                    <A HREF="/date?Europe/Lisbon">Lisbon/Portugal</A>           <A HREF="/date?Europe/Skopje">Skopje</A>
<A HREF="/date?Europe/Belfast">Belfast</A>                   <A HREF="/date?Europe/Ljubljana">Ljubljana</A>                 <A HREF="/date?Europe/Sofia">Sofia</A>
<A HREF="/date?Europe/Belgrade">Belgrade</A>                  <A HREF="/date?Europe/London">London/GB</A>                 <A HREF="/date?Europe/Stockholm">Stockholm/Gnesta</A>
<A HREF="/date?Europe/Berlin">Berlin</A>                    <A HREF="/date?Europe/Luxembourg">Luxembourg</A>                <A HREF="/date?Europe/Tallinn">Tallinn</A>
<A HREF="/date?Europe/Bratislava">Bratislava</A>                <A HREF="/date?Europe/Madrid">Madrid</A>                    <A HREF="/date?Europe/Tirane">Tirane</A>
<A HREF="/date?Europe/Brussels">Brussels</A>                  <A HREF="/date?Europe/Malta">Malta</A>                     <A HREF="/date?Europe/Vaduz">Vaduz</A>
<A HREF="/date?Europe/Bucharest">Bucharest</A>                 <A HREF="/date?Europe/Minsk">Minsk</A>                     <A HREF="/date?Europe/Vienna">Vienna</A>
<A HREF="/date?Europe/Budapest">Budapest</A>                  <A HREF="/date?Europe/Monaco">Monaco</A>                    <A HREF="/date?Europe/Vilnius">Vilnius</A>
<A HREF="/date?Europe/Chisinau">Chisinau</A>                  <A HREF="/date?Europe/Moscow">Moscow</A>                    <A HREF="/date?Europe/Warsaw">Warsaw/Poland</A>
<A HREF="/date?Europe/Copenhagen">Copenhagen</A>                <A HREF="/date?Europe/Oslo">Oslo</A>                      <A HREF="/date?Europe/Zagreb">Zagreb</A>
<A HREF="/date?Europe/Dublin">Dublin/Eire</A>               <A HREF="/date?Europe/Paris">Paris</A>                     <A HREF="/date?Europe/Zurich">Zurich</A>
<A HREF="/date?Europe/Gibraltar">Gibraltar</A>                 <A HREF="/date?Europe/Prague">Prague</A>                    <A HREF="/date?"></A>
<A HREF="/date?Europe/Helsinki">Helsinki</A>                  <A HREF="/date?Europe/Riga">Riga</A>                      <A HREF="/date?"></A>
<A HREF="/date?Europe/Istanbul">Istanbul/Turkey</A>
</PRE>
<H4>Indian</H4>
<PRE>
<A HREF="/date?Indian/Antananarivo">Antananarivo</A>              <A HREF="/date?Indian/Comoro">Comoro</A>                    <A HREF="/date?Indian/Mayotte">Mayotte</A>
<A HREF="/date?Indian/Chagos">Chagos</A>                    <A HREF="/date?Indian/Mahe">Mahe</A>                      <A HREF="/date?Indian/Reunion">Reunion</A>
<A HREF="/date?Indian/Christmas">Christmas</A>                 <A HREF="/date?Indian/Maldives">Maldives</A>                  <A HREF="/date?"></A>
<A HREF="/date?Indian/Cocos">Cocos</A>                     <A HREF="/date?Indian/Mauritius">Mauritius</A>
</PRE>
<H4>Mexico</H4>
<PRE>
<A HREF="/date?Mexico/BajaNorte">BajaNorte</A>                 <A HREF="/date?Mexico/General">General</A>                   <A HREF="/date?"></A>
<A HREF="/date?Mexico/BajaSur">BajaSur</A>
</PRE>
<H4>Mideast</H4>
<PRE>
<A HREF="/date?Mideast/Riyadh87">Riyadh87</A>                  <A HREF="/date?Mideast/Riyadh89">Riyadh89</A>                  <A HREF="/date?"></A>
<A HREF="/date?Mideast/Riyadh88">Riyadh88</A>
</PRE>
<H4>Pacific</H4>
<PRE>
<A HREF="/date?Pacific/Auckland">Auckland/NZ</A>               <A HREF="/date?Pacific/Honolulu">Honolulu/HST</A>              <A HREF="/date?Pacific/Ponape">Ponape</A>
<A HREF="/date?Pacific/Chatham">Chatham/NZ-CHAT</A>           <A HREF="/date?Pacific/Kiritimati">Kiritimati</A>                <A HREF="/date?Pacific/Port_Moresby">Port_Moresby</A>
<A HREF="/date?Pacific/Easter">Easter</A>                    <A HREF="/date?Pacific/Kwajalein">Kwajalein/Kwajalein</A>       <A HREF="/date?Pacific/Rarotonga">Rarotonga</A>
<A HREF="/date?Pacific/Efate">Efate</A>                     <A HREF="/date?Pacific/Majuro">Majuro</A>                    <A HREF="/date?Pacific/Samoa">Samoa</A>
<A HREF="/date?Pacific/Enderbury">Enderbury</A>                 <A HREF="/date?Pacific/Marquesas">Marquesas</A>                 <A HREF="/date?Pacific/Tahiti">Tahiti</A>
<A HREF="/date?Pacific/Fakaofo">Fakaofo</A>                   <A HREF="/date?Pacific/Midway">Midway</A>                    <A HREF="/date?Pacific/Tarawa">Tarawa</A>
<A HREF="/date?Pacific/Fiji">Fiji</A>                      <A HREF="/date?Pacific/Nauru">Nauru</A>                     <A HREF="/date?Pacific/Tongatapu">Tongatapu</A>
<A HREF="/date?Pacific/Funafuti">Funafuti</A>                  <A HREF="/date?Pacific/Niue">Niue</A>                      <A HREF="/date?Pacific/Truk">Truk</A>
<A HREF="/date?Pacific/Galapagos">Galapagos</A>                 <A HREF="/date?Pacific/Norfolk">Norfolk</A>                   <A HREF="/date?Pacific/Wake">Wake</A>
<A HREF="/date?Pacific/Gambier">Gambier</A>                   <A HREF="/date?Pacific/Noumea">Noumea</A>                    <A HREF="/date?Pacific/Wallis">Wallis</A>
<A HREF="/date?Pacific/Guadalcanal">Guadalcanal</A>               <A HREF="/date?Pacific/Palau">Palau</A>                     <A HREF="/date?Pacific/Yap">Yap</A>
<A HREF="/date?Pacific/Guam">Guam</A>                      <A HREF="/date?Pacific/Pitcairn">Pitcairn</A>                  <A HREF="/date?"></A>
</PRE>
<H4>US</H4>
<PRE>
<A HREF="/date?US/Alaska">Alaska</A>                    <A HREF="/date?US/Eastern">Eastern</A>                   <A HREF="/date?US/Pacific">Pacific</A>
<A HREF="/date?US/Aleutian">Aleutian</A>                  <A HREF="/date?US/Hawaii">Hawaii</A>                    <A HREF="/date?US/Pacific-New">Pacific-New</A>
<A HREF="/date?US/Arizona">Arizona</A>                   <A HREF="/date?US/Indiana-Starke">Indiana-Starke</A>            <A HREF="/date?US/Samoa">Samoa</A>
<A HREF="/date?US/Central">Central</A>                   <A HREF="/date?US/Michigan">Michigan</A>                  <A HREF="/date?"></A>
<A HREF="/date?US/East-Indiana">East-Indiana</A>              <A HREF="/date?US/Mountain">Mountain</A>
</PRE>

<!-- End of output from date-process-zoneinfo.pl -->

<P>
<HR>
<A HREF="http://strix.udac.uu.se:80/insts/antro/bh/award.html">
<IMG SRC="http://www.bsdi.com/icons/external/updates-boring-site.gif"
ALT="[UpDate\'s Most Boring Site Award]">
</A>
</BODY>
';

    # restore TZ environment
    $main'ENV{'TZ'} = $TZ;
}

1;
