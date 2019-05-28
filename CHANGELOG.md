# Changelog

Changes to the Glacier Thickness Database (GlaThiDa) will be documented in this file. The database tables and fields therein are referred to with the format `table.field` (e.g. `T`, `T.MEAN_THICKNESS`). Integers in square brackets (e.g. [123, 456]) refer to the `GlaThiDa_ID` of the impacted surveys.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/). This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html), adapted for data. Given a version number `major.minor.patch`, increment the `major` version when data is added, increment the `minor` version when existing data is changed, and increment the `patch` version when metadata is changed (but data is left unchanged).

## Development

### Data: Fixed
- Change `POLITICAL_UNIT` (`T`, `TTT`) from "SJ" (Svalbard and Jan Mayen) to "NO" (Norway) [218, 342-345, 433-434, 2057-2063, 2065-2071].
- Change `TTT.ELEVATION` from "9999" or "10000" to missing [2218, 2377, 2446, 2471, 2477].

## 3.0.1 (2019-03-12)

### Structure: Fixed
- Switch the affiliations of Evgeny Vasilenko ("Academy of Sciences of Uzbekistan, Uzbekistan") and Rein Vaikmäe ("Tallinn University of Technology, Estonia").
- Use accents in contributor name "Francisco Machío".
- Fix link to external data source ("https://doi.org/10.0.73.62/glamos.thickness.1999_2015.r2018").

### Structure: Changed
- Use official Spanish names in the affiliations of Francisco Navarro ("Universidad Politécnica de Madrid: Escuela Técnica Superior de Ingeniería de Telecomunicación (ETSIT), Spain") and Javier Lapazaran ("Universidad Politécnica de Madrid, Spain"), as requested by Francisco Navarro.
- Update the affiliation of Francisco Machío ("Universidad Internacional de La Rioja (UNIR), Spain"), as requested by Francisco Navarro.

## 3.0.0 (2019-02-01)

### Structure: Added
- Format data as a Frictionless Data [Data Package](http://frictionlessdata.io/specs/data-package/). Add metadata and schemas to the required `datapackage.json`.
- Add this changelog as `CHANGELOG.md`.
- Add "GPR" to allowed values for `T.SURVEY_METHOD`. Change "GPRa/GPRt" to "GPR" [2030]. Change "GPRa" to "GPR" (`T.REMARKS`: "GPRt also conducted") [497]. NOTE: The latter should be split into two surveys, by survey method.
- Add optional field `TTT.PROFILE_ID`. Populate for existing surveys by splitting `TTT.POINT_ID`:
  - [319] `TTT.POINT_ID`: "B1" → `TTT.PROFILE_ID`: "B", `TTT.POINT_ID`: "1"
  - [466] `TTT.POINT_ID`: "0_1" → `TTT.PROFILE_ID`: "0", `TTT.POINT_ID`: "1"
  - [499, 500] `TTT.POINT_ID`: "L20050.1" → `TTT.PROFILE_ID`: "L20050", `TTT.POINT_ID`: "1"
  - [554] `TTT.POINT_ID`: "BH1" → `TTT.PROFILE_ID`: "BH", `TTT.POINT_ID`: "1"
  - [2058] `TTT.POINT_ID`: "S6-1" → `TTT.PROFILE_ID`: "S6", `TTT.POINT_ID`: "1"
  - [2088, 2089] `TTT.POINT_ID`: "E1" → `TTT.PROFILE_ID`: "E", `TTT.POINT_ID`: "1"

### Structure: Changed
- Limit `POLITICAL_UNIT` to [ISO-3166-Alpha-2 country codes](https://www.iso.org/obp/ui/#search/code/).
- Extend `GLACIER_NAME` character limit from 30 to 60.
- Limit `GLACIER_NAME` characters to A-Z (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z), 0-9 (0, 1, 2, 3, 4, 5, 6, 7, 8, 9), - (dash), . (period), : (colon), () (parentheses), / (forward slash), ' (apostrophe), and  (space).
- Extend `GLACIER_ID` character limit from 12 to 14 to accommodate Randolph Glacier Inventory (RGI) identifiers.
- Extend `POINT_ID` character limit from 6 to 8 to accommodate point identifiers with longer formats.
- Make `SURVEY_DATE` an optional field. Change all `SURVEY_DATE` (`T`, `TT`, `TTT`) from "99999999" to "" [5-6, 33-49, 94-95, 99, 103, 107-165, 194-195, 197-211, 308, 310, 314-316, 325-326, 422, 467-485, 501, 505-506, 529-553].
- In the case of multiple dates for `SURVEY_DATE` (`T`, `TT`) and `DEM_DATE`, specify that the first date should be listed.
- Remove character limit for `REMARKS`, `SURVEY_METHOD_DETAILS`, `INVESTIGATOR`, `SPONSORING_AGENCY` and `REFERENCES`.
- Remove numeric limit for `NUMBER_OF_SURVEY_POINTS` and `NUMBER_OF_SURVEY_PROFILES`.
- Implicitly require that both (or neither) `SOURCE_ID` and `GLACIER_ID` be provided by requiring that `SOURCE_ID` specify the database used as the source for `GLACIER_ID`. Change all `T.SOURCE_ID` to "" where `GLACIER_ID` is "" [6, 9, 11-15, 17-24, 27, 32, 45, 68-72, 74-77, 80-90, 117, 121-122, 127-130, 132-134, 136, 154-155, 158, 160, 162-193, 200, 206, 214-218, 229-233, 236, 250, 321, 324, 328, 331-332, 335, 339-340, 352, 357, 359-361, 366, 399, 411, 422-423, 426-428, 446-447, 455, 460-468, 472, 480, 491-496, 499-504, 510, 512, 513, 515-516, 560, 1937, 2027-2055, 2083].
- Rename `SOURCE_ID` to `GLACIER_DB` to clarify that it is the database to which `GLACIER_ID` is meant to refer to. Change "SOURCE_ID" to "GLACIER_DB" in `T.REMARKS` [2104, 2107-2108].
- Rename `DEM_DATE` to `ELEVATION_DATE` to clarify that it is the date of the provided elevations, regardless of whether the elevations were extracted from a digital elevation model (DEM). Change "DEM_DATE" to "ELEVATION_DATE" in `T.REMARKS` [2091].

### Structure: Removed
- Header lines containing a table label (e.g. "TTT GLACIER THICKNESS POINT DATA") and field codes (e.g. "TTT1") in `TT` and `TTT`, and a line containing field units (e.g. "numeric code") in `T`, `TT` and `TTT`. Having a single header line with field names (e.g. "GlaThiDa_ID,...") maximizes the machine-readability of the data files.

### Data: Added
- Survey (`T`, `TT`, `TTT`) of Athabasca Glacier, Canada submitted by Ian Raphael [2094]. `T.INVESTIGATOR` also lists Robert Hawley.
- Survey (`T`, `TT`, `TTT`) of Lötschengletscher, Switzerland submitted by Eliane Brändle and Enrico Mattea [2095].
- Surveys (`T`, `TT`, `TTT`) of glaciers in China submitted by Huilin Li [2096-2100].
- Survey (`T`, `TTT`) of Qaanaaq Ice Cap, Greenland submitted by Izumi Asaji [2101]. `T.INVESTIGATOR` lists Shin Sugiyama.
- Surveys (`T`, `TTT`) of glaciers in Greenland submitted by Jakob Abermann [2102-2103]. `T.INVESTIGATOR` also lists Jakob Steiner, Rainer Prinz, and Peter Lisager.
- Surveys (`T`, `TTT`) of glaciers in Norway compiled and submitted by Liss M. Andreassen [2104-2108]. `T.INVESTIGATOR` lists Kjetil Melvold and Michael Kennett.
- Surveys (`T`, `TTT`) of glaciers in Svalbard and Kazakhstan submitted by Ivan Lavrentiev [2109-2122].
- Survey (`T`, `TTT`) of Aldegondabreen, Svalbard submitted by Francisco Navarro [2123].
- Survey (`T`, `TT`, `TTT`) of Mount Kilimanjaro, Tanzania submitted by Pascal Bohleber [2124] (https://doi.org/10.1594/PANGAEA.849390).
- Surveys (`T`, `TTT`) of glaciers in Switzerland submitted by Andreas Bauder and Matthias Huss [2125-2187] (https://doi.org/10.18750/glamos.thickness.1999_2015.r2018).
- Surveys (`T`, `TTT`) of glaciers in Svalbard compiled and submitted by Francisco Navarro and Johannes Fürst [2188-2499] (including https://doi.org/10.21334/npolar.2017.702ca4a7). `T.INVESTIGATOR` also lists the following:
  - Julian A. Dowdeswell and Toby J. Benham - Scott Polar Research Institute, United Kingdom
  - Rickard Pettersson - Uppsala University, Sweden
  - Jacek Jania, Mariusz Grabiec - University of Silesia in Katowice, Poland
  - Javier Lapazaran, Francisco Machio - Technical University of Madrid, Spain
  - Evgeny Vasilenko - Academy of Sciences of Uzbekistan, Uzbekistan
  - Victor S. Zagorodnov, Serguei M. Arkhipov, Vladimir Kotlyakov - Russian Academy of Sciences: Institute of Geography, Russia
  - Thomas V. Schuler, Svein-Erik Hamran, Jon Ove Hagen - University of Oslo, Norway
  - Kjetil Melvold - Norwegian Water Resources and Energy Directorate (NVE), Norway
  - Helgi Björnsson, Finnur Pálsson - University of Iceland, Reykjavik
  - David Rippin - University of York, United Kingdom
  - Albane Saintenoy - University of Paris-Sud, France
  - Songtao Ai - Wuhan University, China
  - Douglas I. Benn, Heïdi Sevestre - University of Saint Andrews, United Kingdom
  - Jack Kohler, Katrin Lindbäck, Elisabeth Isaksson - Norwegian Polar Institute, Norway
  - Yoshiyuki Fujii - National Institute of Polar Research, Japan
  - Rein Vaikmäe - Tallinn University of Technology, Estonia
  - Steen Savstrup Kristensen - Technical University of Denmark: Department of Space Research and Space Technology (DTU Space), Denmark
  - Ya.-M.K. Punning - Estonian Academy of Sciences (USSR Academy of Sciences-Estonia): Institute of Geology, Estonia
- Surveys (`T`, `TTT`) of glaciers in Greenland, Canada, Antarctica, Svalbard and the United States (Alaska) extracted from IceBridge data intersected with Randolph Glacier Inventory (RGI6.0) glacier outlines [2500-6623].
  - [Pre-IceBridge MCoRDS L2 Ice Thickness, Version 1](https://doi.org/10.5067/QKMTQ02C2U56) (1993-06-23 to 2007-09-23)
  - [IceBridge MCoRDS L2 Ice Thickness, Version 1](https://doi.org/10.5067/GDQ0CUCVTE2Q) (2009-10-16 to 2017-11-25)
  - [IceBridge HiCARS 1 L2 Geolocated Ice Thickness, Version 1](https://doi.org/10.5067/F5FGUT9F5089) (2009-01-02 to 2010-12-21)
  - [IceBridge HiCARS 2 L2 Geolocated Ice Thickness, Version 1](https://doi.org/10.5067/9EBR2T0VXUDG) (2010-12-05 to 2013-01-20)
  - [IceBridge PARIS L2 Ice Thickness, Version 1](https://doi.org/10.5067/OMEAKG6GIJNB) (2009-04-01 to 2009-05-02)
  - [IceBridge WISE L2 Ice Thickness and Surface Elevation, Version 1](https://doi.org/10.5067/0ZBRL3GY720R) (2012-03-16 to 2012-03-25)

### Data: Removed
- Surveys (`T`, `TTT`) extracted from IceBridge data intersected with Randolph Glacier Inventory (RGI3.2) glacier outlines [1000-1932].
- Elevation intervals (`TT`) with missing `TT.MEAN_THICKNESS` (required field) [2012, 2093: previously 2010 CHARQUINI SUR].
- Survey (`T`, `TTT`) of JOSTEDALSBREEN [2064], which has incorrect surface elevations. It is replaced by [2108].
- Survey (`T`) of SILVRETTA [354]. It is replaced by [2171], which includes point-level data.
- Surveys (`T`) of KONGSVEGEN, UVERSBREEN, MIDTRE LOVENBREEN, and AUSTRE BROEGGERBREEN [255-228]. They are replaced by [2452, 2338, 2326, 2334], which include point-level data.

### Data: Fixed
- Fix or remove incorrect unicode characters (e.g. "†AJUSAISKII" → "AJUSAISKII", "BL≈" → "BLÅ", "Bjˆrnsson" → "Björnsson").

#### `GlaThiDa_ID`
- Change `T.GlaThiDa_ID` from [2004, 2004-2008, 2015] to [2004-2010] to point to correct entries in `TT` and `TTT`.
- Change `GlaThiDa_ID` (`T`, `TT`, `TTT`) for CHARQUINI SUR from [2010] to [2093] to remove duplicate use of [2010].

#### `POLITICAL_UNIT`
- Change `TTT.POLITICAL_UNIT` for MARUKH [2074] from "GE" (Georgia) to "RU" (Russia, correct) to match `T.POLITICAL_UNIT`.
- Change `T.POLITICAL_UNIT` from "SU" (Soviet Union, deprecated) to "RU" (Russia, correct) to match `POLITICAL_UNIT` (`TT`, `TTT`) [173, 176, 180, 183, 192, 339-340, 491].
- Change `T.POLITICAL_UNIT` from "AT" (Austria) to "IT" (Italy) [250].
- Change `POLITICAL_UNIT` (`T`, `TTT`) from "AT" (Austria) to "IT" (Italy) [1966].
- Change `POLITICAL_UNIT` (`T`, `TT`, `TTT`) from "NO" (Norway) to "SJ" (Svalbard and Jan Mayen) [109-167, 194-195, 205, 218, 225-228, 342-345, 359, 423-485, 498, 509-510, 560, 2057-2071, 2075-2076].

#### `GLACIER_NAME`
- Change `TT.GLACIER_NAME` from "SCHLADMINGER" to "SCHLADMINGER GLETSCHER" (more complete) to match `T.GLACIER_NAME` [104].
- Change `TTT.GLACIER_NAME` from "SULDENFERNER" to "SULDENFERNER (SOUTH)" (more complete) to match `T.GLACIER_NAME` [1946].
- Change `TTT.GLACIER_NAME` from "GURGLER" to "GURGLERFERNER" (more complete) to match `T.GLACIER_NAME` [1962].
- Change `TT.GLACIER_NAME` from "URUMQI NO.1" to "URUMQI GLACIER NO.1" (more complete) to match `T.GLACIER_NAME` [2083].
- Change `T.GLACIER_NAME` from "WEISSEEFERNER" to "WEISSSEEFERNER" (correct transliteration of "Weißseeferner") to match `TTT.GLACIER_NAME` [2008].
- Change `T.GLACIER_NAME` from "PLANNEVE" to "PLAN NEVE" (preferred) to match `GLACIER_NAME` (`TT`, `TTT`) [2018].
- Change `GLACIER_NAME` (`T`, `TT`) from "HARDANGERJOKULEN" to "HARDANGERJOEKULEN" (correct transliteration of "Hardangerjøkulen") to match `TTT.GLACIER_NAME` [2068].

#### `SOURCE_ID`
- Change `T.SOURCE_ID` from "WGMS" (invalid value) to "FOG" (correct value) [5, 7-8, 25, 33-34, 38-44, 46-47, 73, 92, 161, 196, 202, 207-208, 210-213, 224, 304, 307, 310-312, 315, 317, 320, 322-323, 325, 329-330, 337, 343, 347-351, 354-356, 358, 363, 505-506, 512-513, 528, 2011, 2086-2089].

#### `GLACIER_ID`
- Change `T.GLACIER_ID` from "726SU4G08005062" (invalid for `T.SOURCE_ID`: "WGI") to "SU4G08005062" [327].

#### `SURVEY_DATE`
- Change `T.SURVEY_DATE` from "99999999" to "19929999" (more complete) to match `TTT.SURVEY_DATE` [33].
- Change `TTT.SURVEY_DATE` from "19769999" to "19760328" (more complete) to match `T.SURVEY_DATE` [319].
- Change `SURVEY_DATE` (`TT`, `TTT`) from "20109999" to "20100216" (more complete) to match `T.SURVEY_DATE` [362].
- Change `TTT.SURVEY_DATE` from "20099999" to "20090799" (more complete) to match `T.SURVEY_DATE` [466].
- Change `SURVEY_DATE` (`TT`, `TTT`) from "20069999" to "20061107" (more complete) to match `T.SURVEY_DATE` [486, 487].
- Change `SURVEY_DATE` (`TT`, `TTT`) from "20109999" to "20100917" (more complete) to match `T.SURVEY_DATE` [488].
- Change `SURVEY_DATE` (`TT`, `TTT`) from "20079999" to "20071003" (more complete) to match `T.SURVEY_DATE` [489].
- Change `SURVEY_DATE` (`TT`, `TTT`) from "20079999" to "20071002" (more complete) to match `T.SURVEY_DATE` [490].
- Change `TTT.SURVEY_DATE` from "20109999" to "20089999" (`TTT.REMARKS` ~ "2008") or "20129999" (`TTT.REMARKS` ~ "2012") and change `T.SURVEY_DATE` from "20129999" to average "2010999" [497]. NOTE: Should be split into two surveys, by date.
- Change `TTT.SURVEY_DATE` from "20029999" to "20020599" (`TTT.REMARKS` ~ "HEM data"), "20060799" (`TTT.REMARKS` ~ "GPR data"), or "19359999" (`TTT.REMARKS` ~ "Drilling hole data") (See https://doi.org/10.3189/2012JoG11J098) [499]. NOTE: Should be split into three surveys, by date and survey method.
- Change `TTT.SURVEY_DATE` from "20029999" to "20020599" (more complete) to match `T.SURVEY_DATE` [500].
- Change `TTT.SURVEY_DATE` from "20079999" to "20070729" (more complete) to match `T.SURVEY_DATE` [554].
- Change `TTT.SURVEY_DATE` of first point from "19989999" to "20039999", and change `T.SURVEY_DATE` from "20039999" to "19989999" since majority of points are from the 1998 survey (https://doi.pangaea.de/10.1594/PANGAEA.849497) [1976]. NOTE: Should be split into two surveys, by date.
- Change `T.SURVEY_DATE` from "20029999" to "19999999" (https://doi.pangaea.de/10.1594/PANGAEA.849488) to match `TTT.SURVEY_DATE` [2010].
- Change `TT.SURVEY_DATE` from "20130399" to "20131003" to match `SURVEY_DATE` (`T`, `TTT`) [2018].
- Change `TT.SURVEY_DATE` from "20130399" to "20110399" to match `SURVEY_DATE` (`T`, `TTT`) [2019].
- Change `TTT.SURVEY_DATE` from "20052604", "20052704" (YYYYDDMM) to "20050426", "20050427" (YYYYMMDD) [2057].
- Change `TTT.SURVEY_DATE` from "20060905" (YYYYDDMM) to "20060509" (YYYYMMDD) to match `T.SURVEY_DATE` (see https://www.nve.no/Media/7200/data_istykkelse_nve_v2-0_2018.zip) [2058].
- Change `T.SURVEY_DATE` from "20120809" (YYYYDDMM) to "20120908" (YYYYMMDD) to match `TTT.SURVEY_DATE` (see https://www.nve.no/Media/7200/data_istykkelse_nve_v2-0_2018.zip) [2061].
- Change `TTT.SURVEY_DATE` from "20082105", "20081303" (YYYYDDMM) to "20080521", "20080313" (YYYYMMDD) (see https://www.nve.no/Media/7200/data_istykkelse_nve_v2-0_2018.zip) [2062]. NOTE: Should be split into two surveys, by date.
- Change `T.SURVEY_DATE` from "31032014" (DDMMYYYY) to "20040331" (YYYYMMDD) (see https://www.nve.no/Media/7200/data_istykkelse_nve_v2-0_2018.zip) [2065].
- Change `T.SURVEY_DATE` from "22.04.2004 00:00" (MM.DD.YYYY hh:mm) to "20040421" (YYYYMMDD) to match earliest date in `TTT.SURVEY_DATE` (see https://www.nve.no/Media/7200/data_istykkelse_nve_v2-0_2018.zip) [2067].
- Change `T.SURVEY_DATE` from "20100318" to "19860520" to match `TTT.SURVEY_DATE` (see https://www.nve.no/Media/7200/data_istykkelse_nve_v2-0_2018.zip) [2071].
- Change `TTT.SURVEY_DATE` from "20140405" to "20140406" to match `T.SURVEY_DATE` [2075]. NOTE: The correct date may be "20150406", since https://doi.org/10.3189/2015JoG15J141 mentions "5–7 April 2015", although http://svalglac.eu/Inventory_shpArcGIS_layers.zip has "2014".
- Change `T.SURVEY_DATE` from "" to "19869999" to match `TTT.SURVEY_DATE` [2082].
- Change `TTT.SURVEY_DATE` from "2013" (YYYY) to "20139999" (YYYYMMDD) to match `T.SURVEY_DATE` [2085].
- Change `TTT.SURVEY_DATE` from "2009" (YYYY) to "20099999" (YYYYMMDD) to match `T.SURVEY_DATE` [2086].
- Change `TTT.SURVEY_DATE` from "20069999" to "20060899" (more complete) to match `T.SURVEY_DATE` [2087].
- Change `TT.SURVEY_DATE` from "20069999" to "20060899" (more complete) and `TTT.SURVEY_DATE` from "2006" to "20060899" (more complete) to match `T.SURVEY_DATE` [2088, 2089].
- Change `T.SURVEY_DATE` from "20150814" to "20140815" (http://orbit.dtu.dk/files/134812923/aaar0016_049.pdf, "12–17 August 2014") to match `TTT.SURVEY_DATE` [2092].
- Change `SURVEY_DATE` (`T`, `TTT`) from "19969999" to "19959999" (https://doi.pangaea.de/10013/epic.45983.d001, "1995") [1937].

#### `DEM_DATE`
- Change `T.DEM_DATE` from "20100318" to "19860520" to match `TTT.SURVEY_DATE` (see https://www.nve.no/Media/7200/data_istykkelse_nve_v2-0_2018.zip) [2071].
- Change `T.DEM_DATE` from "20109999" to "20069999" (`TTT.REMARKS`: "Year: Date of DEM 2006") [362].
- Change `T.DEM_DATE` from "19979999" to "19959999" (`TTT.REMARKS`: "Year of elevation: 1995;...") [1937].
- Change `T.DEM_DATE` from "99999999" to "" [5-6, 33-49, 91-92, 94-95, 99, 103, 107-165, 194-195, 197-211, 308, 310, 314-316, 325-326, 422, 467-485, 501, 529-553, 2072-2073, 2090].

#### `POINT_ID`
- Assign sequential `TTT.POINT_ID` (1, 2, ...) to points with missing values and append "TTT.POINT_ID assigned in order of submission." to `T.REMARKS`  [2079].
- Append ".1" to the second of sequential duplicate `TTT.POINT_ID` to enforce uniqueness [2057-2058].

#### `T.LAT`, `T.LON` / `TTT.POINT_LAT`, `TTT.POINT_LON`
- Fix point coordinates (`TTT.POINT_LON`, `TTT.POINT_LAT`) for 1937 WEISSBRUNNFERNER by assigning EPSG:32632 (WGS 84 / UTM zone 32N) to the original dataset (https://doi.pangaea.de/10.1594/PANGAEA.849336), then transform to EPSG:4326 (WGS 84).
- Fix `T.LON` for some Russian glaciers by removing negative sign [339-340, 491].
- Fix `T.LON` for AGASSIZ ICE CAP from "0.75" to "-75.0" [211].

#### `SURVEY_METHOD_DETAILS`
- Change `T.SURVEY_METHOD_DETAILS` from "SURVEY_METHOD_DETAILS" to "Narod GPR, 6.5MHz, wave velocity 0.168m/ns" (based on similar surveys and `TTT.REMARKS`) [1934].

#### `INTERPOLATION_METHOD`
- Change `T.INTERPOLATION_METHOD` from "TIN" (invalid value) to "TRI" [2045-2055].

#### `NUMBER_OF_SURVEY_POINTS`
- Fill empty `T.NUMBER_OF_SURVEY_POINTS` with the number of points in `TTT` [33, 466, 499-502, 2027-2033, 2082].

#### `INVESTIGATOR`
- Change `T.INVESTIGATOR` from "Glenn FLOWERS" to "Gwenn FLOWERS" [2078-2079].

#### `DATA_FLAG`
- Change `T.DATA_FLAG` from "Error in logging profiles, thus only point data" (invalid value) to "" and append instead to `T.REMARKS` [2057, 2058].
- Change `TTT.DATA_FLAG` from "2" (invalid value) to "" [2012].

#### `REMARKS`
- Replace field codes with field names ("FieldT9" → "T.DEM_DATE", "TTT8" → "TTT.ELEVATION") in `T.REMARKS` [2091].
- Change `REMARKS` (`TT`, `TTT`) to "" when equal for all points and included elsewhere [362, 500, 2011-2012, 2073, 2085-2086, 2091-2092, 2093: previously 2010 CHARQUINI SUR].
- Append `TTT.REMARKS` to `T.REMARKS` and change to "" when equal for all points and not included in `T.REMARKS` [33, 502, 554, 1938-1946, 2013-2025, 2061, 2075-2076, 2078, 2080].
- Change `TTT.REMARKS` to "" and append the following to `T.REMARKS`:
  - [499] "TTT.SURVEY_DATE: 19359999 Drilling hole data from Finn et al., (2012). Jour. Glac. Based on Fowler, C.S., (1936). Msc Thesis. Survey in 1930s, but specific year unknown. // TTT.SURVEY_DATE: 20020599 HEM data from Finn et al., (2012). Jour. Glac. // TTT.SURVEY_DATE: 20060799 GPR data from Finn et al., (2012). Jour. Glac. based on Tulaczyk, S., (2006). Pers. Comm."
  - [501] "GPR data from Finn et al., (2012). Jour. Glac. based on Tucker et al., (2009). Geol. Soc. US."
  - [2057] "Thickness includes winter snow 2005 (See Glac. Inv. Norway 2005, NVE Report 2-2006, p. 53)"
  - [2058] "Elevation from same day GNSS survey. Thickness includes winter snow 2006 (See Glac. Inv. Norway 2006, NVE Report 1-2007)"
  - [2059, 2060] "Elevation from same day GNSS survey. Thickness includes winter snow 2011 (Data: NVE)"
  - [2062] "Thickness includes winter snow 2008 (See Glac. Inv. Norway 2008, NVE Report 2-2009, p. 71)"
- Change `TTT.REMARKS` to "" and append the following to `T.SURVEY_METHOD_DETAILS`:
  - [1947-2010] "antenna length 15/25m. Narod and Clarke (1994)"
  - [1933-1937] "Narod and Clarke (2014)"

## 2.1.0 (2016-10-27)

### Structure: Changed
- Remame `T_2016.csv`, `TT_2016.csv`, and `TTT_2016.csv` to `T_2016_corr.csv`, `TT_2016_corr.csv`, and `TTT_2016_corr.csv`, respectively.
- Add description of changes to `WGMS_glathida_2016.txt`.

### Data: Fixed
- Switch values in `TTT.POINT_LAT` and `TTT.POINT_LON` for some glaciers in Norway, Chile, China, and Switzerland [497, 2027-2033, 2057-2065, 2067-2071, 2085, 2091].
- Change `TTT.SURVEY_DATE` from "4739999" to "20079999" to more closely match `T.SURVEY_DATE` ("20070729") [554].
- Change `TTT.ELEVATION` from "#REF!" to "259" for `TTT.POINT_ID`: 9288 [2071].

### Data: Removed
- Point (`TTT`) with outlier `TTT.POINT_LON` (`TTT.POINT_ID`: 1) [2083]. `TTT.POINT_ID` of the remaining points were shifted down by 1 (e.g. from "2" to "1", from "3" to "2").

## 2.0.0 (2016-07-04)

### Structure: Added
- Add `T.DEM_DATE` (YYYYMMDD) for the date of the elevation data used for surface elevation fields (e.g. `TT.LOWER_BOUND`, `TTT.ELEVATION`) and backfill the field for some existing surveys [1-3, 220, 319, 321, 329, 333, 336-337, 342, 348, 359, 362, 364, 423-427, 429, 431, 433, 435, 437-438, 440, 442, 444, 466, 486-490, 497-500, 505-506, 511, 514, 516, 528, 554, 560].
- Add `T.SURVEY_METHOD_DETAILS` for details of the survey method which can be used to assess the uncertainty of the ice thickness measurements.
- Add `DATA_FLAG` (`T`, `TT`, `TTT`) to flag ice thickness data known to be erroneous or limited to glacier parts (`T` and `TT` only).
- Add "FOG" (Fluctuations of Glaciers) and "GLIMS" (Global Land Ice Measurements from Space) to the list of values allowed in `T.SOURCE_ID`.

### Structure: Changed
- Rename `WGMS_glathida_2014.txt` to `WGMS_glathida_2016.txt` and update for the new release.
- Rename `GlaThiDa_documentation.pdf` to `GlaThiDa_2016_documentation.pdf` and update for the new release.
- Remame `T.csv`, `TT.csv`, and `TTT.csv` to `T_2016.csv`, `TT_2016.csv`, and `TTT_2016.csv`, respectively.
- Switch from using ";" (semicolon) to "," (comma) as the delimiter in `T`, `TT`, and `TTT`.
- Rename `ID` to `GLACIER_ID`.
- Rename `ACCURACY_MEAN_THICKNESS` to `MEAN_THICKNESS_UNCERTAINTY` (`T`, `TT`).
- Rename `ACCURACY_MAX_THICKNESS` to `MAX_THICKNESS_UNCERTAINTY` (`T`, `TT`).
- Rename `TTT.ACCURACY_THICKNESS` to `TTT.THICKNESS_UNCERTAINTY`.
- Rename `YEAR` (`TT`, `TTT`) to `SURVEY_DATE` to match `T.SURVEY_DATE`.
- Change "RGI3.2" (Randolph Glacier Inventory, version 3.2) to "RGI" (Randolph Glacier Inventory) in the list of values allowed in `T.SOURCE_ID`, since the RGI version is part of any RGI glacier identifier.
- Change the limit on `T.LAT`, `T.LON` from 7 digits to 6 decimal places.
- Change the limit on `AREA` (`T`, `TT`) from 6 digits to 5 decimal places.
- Change the limit on `T.TOTAL_LENGTH_OF_SURVEY_PROFILES` from 4 digits to 2 decimal places.
- Change the limit on `TTT.POINT_LAT`, `TTT.POINT_LON` from 10 digits to 7 decimal places.
- Extend the limit on `TTT.THICKNESS` from 4 to 6 digits.

### Structure: Removed
- The 1 047 076 empty rows at the end of `T`.
- The 10 empty rows at the end of `TT`.
- The 1 empty column at the end of `TT`.
- The 48 empty columns at the end of `TTT`.
- Header lines in `T` containing a table label ("T GLACIER THICKNESS OVERVIEW...") and field codes ("T1;T2;...").
- Field `T.YEAR` (YYYY of survey), which was redundant given the presence of `T.SURVEY_DATE` (YYYYMMDD of survey).

### Data: Added
- Surveys (`T`, `TTT`) of glaciers in South Tyrol, Italy submitted by Kay Helfricht [1933-1946] (https://doi.org/10.1594/PANGAEA.849390). `T.INVESTIGATOR` lists Andrea Fischer, Christian Mitterer, Bernd Seiser, Martin Stocker-Waldhuber, Lea Hartl, Jakob Abermann, Gerhard Markl, Daniel Binder, and Stefan Scheiblauer.
- Surveys (`T`, `TTT`) of glaciers in Austria submitted by Kay Helfricht [1947-2008 (including two 2004), 2015 VERNAGTFERNER] (https://doi.org/10.1594/PANGAEA.849497). `T.INVESTIGATOR` lists Andrea Fischer.
- Surveys (`T`, `TT`, `TTT`) of glaciers in Bolivia and Colombia submitted by Antoine Rabatel [2010-2012]. `T.INVESTIGATOR` for LA CONEJERAS [2011] also lists Jorge Luis Ceballos, Michael Zemp, and Felipe Echeverry.
- Surveys (`T`, `TT`, `TTT`) of glaciers in Switzerland submitted by Matthias Huss [2013-2014, 2015 GURSCHEN, 2016-2026]. `T.INVESTIGATOR` also lists Mauro Fischer.
- Surveys (`T`, `TTT`) of glaciers in Chile submitted by Marius Schaefer [2027-2055]. `T.INVESTIGATOR` lists Gino Casassa, Norbert Blindow, José Luis Rodríguez Lagos, Andrés Rivera, and Rodrigo Zamora.
- Surveys (`T`,  `TTT`) of glaciers in Norway submitted by Liss Marie Andreassen [2057-2071]. `T.INVESTIGATOR` also lists Hallgeir Elvehøy, Kjetil Melvold, Ingvild Sørdal, Erlend Førre, Jostein Bakke, Michael Kennett, Bjarne Kjøllmoen, Rune Engeset, Tron Laumann, and Arne Chr. Sætrang.
- Surveys (`T`, `TT`, `TTT`) of glaciers in Russia submitted by Stanislav Kutuzov [2072-2074]. `T.INVESTIGATOR` lists Ivan Lavrentiev.
- Surveys (`T`, `TTT`) of glaciers in Svalbard submitted by Francisco Navarro [2075-2076].
- Surveys (`T`, `TTT`) of glaciers in New Zealand, Canada, Antarctica, and China compiled and submitted by Daniel Farinotti [2077-2084]. `T.INVESTIGATOR` and submission notes also list Gwenn E. Flowers (misspelled "Glenn Flowers"), Huilin Li, and John Sanders as contributors, Brian Anderson as compiler, and Robert W. Jacobel, Ian Owens, Nat J. Wilson, and Laurent Mingo as investigators.
- Surveys (`T`, `TT`, `TTT`) of glaciers in China submitted by Huilin Li [2085-2089].
- Survey (`T`, `TTT`) of Sary Tor, Kyrgyzstan submitted by Ivan Lavrentiev [2090].
- Survey (`T`, `TTT`) of Tiefengletscher, Switzerland by Andri Moll and Horst Machguth [2091].
- Survey (`T`, `TTT`) of Aqqutikitsoq, Greenland by Elisa Bjerre and Peter Alexander Stentoft [2092].

### Data: Removed
- Surveys (`T`) of glaciers in Austria and Italy [239-249, 251-303]. They are replaced by [1943, 1947-1959, 1961-2008 (including two 2004), 2015 VERNAGTFERNER], which include point-level data.

### Data: Fixed
- Change `T.POLITICAL_UNIT` from "SU" (Soviet Union, deprecated) to "RU" (Russia) [35-38, 47, 67, 168-172, 174-175, 177-179, 181-182, 184-191, 193, 197-198, 327, 346, 366-405, 407-496]
- Change `T.POLITICAL_UNIT` from "SU" (Soviet Union, deprecated) to "KG" (Kyrgyzstan) [39-41, 43, 46].
- Change `T.POLITICAL_UNIT` from "SU" (Soviet Union, deprecated) to "CN" (China) [42, 406].
- Change `T.POLITICAL_UNIT` from "SU" (Soviet Union, deprecated) to "KZ" (Kazakhstan) [44, 48-66, 68-92, 505-506].
- Change `T.POLITICAL_UNIT` from "SU" (Soviet Union, deprecated) to "GE" (Georgia) [326].
- Change `T.POLITICAL_UNIT` from "SU" (Soviet Union, deprecated) to "TJ" (Tajikistan) [45].
- Append "POLITICAL_UNIT updated by spatial query with data from gadm.org." to `T.REMARKS` [45, 48-91, 326-327, 346, 366-421].
- Replace special characters in `T.GLACIER_NAME` by the transliteration rules in `GlaThiDa_2016_documentation.pdf` [113-115, 119, 127, 130, 133-134, 139, 143, 148, 156, 160, 163, 228, 427-428, 437, 467, 473, 477-478, 511].
- Add missing "FERNER" suffix to `T.GLACIER_NAME` [96, 101].
- Change `T.GLACIER_NAME` from "GRINNER FERNER" to "GRINNERFERNER" (no space) [238].
- Change `T.GLACIER_NAME` from "DAOGELFERNER" (misspelling) to "DAUNKOGELFERNER" [308].
- Change `T.GLACIER_NAME` from "GLACIER URUMQI NO. #" to "URUMQI GLACIER NO. #" [529-533].
- Update `T.LAT`, `T.LON` with higher precision and/or more accurate coordinates [40, 93, 95-96, 98, 105-106, 311, 313-314, 317, 331, 343-346, 357, 433-434, 515-518, 524, 527].
- Round `TTT.ELEVATION` from 1 to 0 decimal places as required by `GlaThiDa_2016_documentation.pdf` [33, 319, 362, 466, 486-490, 497, 499-502, 554].
- Round `TTT.THICKNESS` from 2 to 0 decimal places as required by `GlaThiDa_2016_documentation.pdf` [33, 319, 362, 466, 486-490, 497, 499-502, 554].
- Round `TTT.THICKNESS_UNCERTAINTY` from 1 or 2 to 0 decimal places as required by `GlaThiDa_2016_documentation.pdf` [33, 319, 362, 466, 486-490, 497, 499-502, 554].
- Round `TTT.POINT_LAT`, `TTT.POINT_LON` from 8 to 7 decimal places as required by `GlaThiDa_2016_documentation.pdf` [362, 466, 497, 554].
- Switch values in `TTT.POINT_LAT` and `TTT.POINT_LON` [497].

## 1.0.0 (2014-09-25)

The initial release is described in detail in the following journal article:

> Isabelle Gärtner-Roer, Kathrin Naegeli, Matthias Huss, Thomas Knecht, Horst Machguth, Michael Zemp (2014): A database of worldwide glacier thickness observations. Global and Planetary Change. DOI:[10.1016/j.gloplacha.2014.09.003](http://dx.doi.org/10.1016/j.gloplacha.2014.09.003)
