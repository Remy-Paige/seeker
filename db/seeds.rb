# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

am = Country.find_or_create_by(name: 'Armenia')
at = Country.find_or_create_by(name: 'Austria')
ba = Country.find_or_create_by(name: 'Bosnia and Herzegovina')
hr = Country.find_or_create_by(name: 'Croatia')
cy = Country.find_or_create_by(name: 'Cyprus')
cz = Country.find_or_create_by(name: 'Czech Republic')
dk = Country.find_or_create_by(name: 'Denmark')
fi = Country.find_or_create_by(name: 'Finland')
de = Country.find_or_create_by(name: 'Germany')
hu = Country.find_or_create_by(name: 'Hungary')
li = Country.find_or_create_by(name: 'Liechtenstein')
lu = Country.find_or_create_by(name: 'Luxembourg')
me = Country.find_or_create_by(name: 'Montenegro')
nl = Country.find_or_create_by(name: 'Netherlands')
no = Country.find_or_create_by(name: 'Norway')
pl = Country.find_or_create_by(name: 'Poland')
ro = Country.find_or_create_by(name: 'Romania')
rs = Country.find_or_create_by(name: 'Serbia')
sk = Country.find_or_create_by(name: 'Slovakia')
si = Country.find_or_create_by(name: 'Slovenia')
es = Country.find_or_create_by(name: 'Spain')
se = Country.find_or_create_by(name: 'Sweden')
ch = Country.find_or_create_by(name: 'Switzerland')
ua = Country.find_or_create_by(name: 'Ukraine')
gb = Country.find_or_create_by(name: 'United Kingdom')

Language.find_or_create_by(name: 'Albanian').countries << [ba, me, ro, rs]
Language.find_or_create_by(name: 'Aragonese').countries << [es]
Language.find_or_create_by(name: 'Aranese').countries << [es]
Language.find_or_create_by(name: 'Armenian').countries << [cy, hu, pl, ro]
Language.find_or_create_by(name: 'Assyrian').countries << [am]
Language.find_or_create_by(name: 'Asturian').countries << [es]
Language.find_or_create_by(name: 'Basque').countries << [es]
Language.find_or_create_by(name: 'Beás').countries << [hu]
Language.find_or_create_by(name: 'Belarusian').countries << [pl, ua]
Language.find_or_create_by(name: 'Bosnian').countries << [me, rs]
Language.find_or_create_by(name: 'Bulgarian').countries << [hu, ro, rs, sk, ua]
Language.find_or_create_by(name: 'Bunjevac').countries << [rs]
Language.find_or_create_by(name: 'Catalan').countries << [es]
Language.find_or_create_by(name: 'Cornish').countries << [gb]
Language.find_or_create_by(name: 'Crimean Tatar').countries << [ua]
Language.find_or_create_by(name: 'Croatian').countries << [at, cz, hu, me, ro, rs, sk, si]
Language.find_or_create_by(name: 'Cypriot Maronite Arabic').countries << [cy]
Language.find_or_create_by(name: 'Czech').countries << [at, ba, hr, pl, ro, rs, sk]
Language.find_or_create_by(name: 'Danish').countries << [de]
Language.find_or_create_by(name: 'Finnish').countries << [se]
Language.find_or_create_by(name: 'French').countries << [ch]
Language.find_or_create_by(name: 'Frisian').countries << [nl]
Language.find_or_create_by(name: 'Gagauz').countries << [ua]
Language.find_or_create_by(name: 'Galician').countries << [es]
Language.find_or_create_by(name: 'German').countries << [am, ba, hr, cz, dk, hu, pl, ro, rs, sk, si, ch, ua]
Language.find_or_create_by(name: 'Greek').countries << [am, hu, ro, ua]
Language.find_or_create_by(name: 'Hungarian').countries << [at, ba, hr, ro, rs, sk, si, ua]
Language.find_or_create_by(name: 'Inari Sami').countries << [fi]
Language.find_or_create_by(name: 'Irish').countries << [gb]
Language.find_or_create_by(name: 'Istro-Romanian').countries << [hr]
Language.find_or_create_by(name: 'Italian').countries << [ba, hr, ro, si, ch]
Language.find_or_create_by(name: 'Karaim').countries << [pl, ua]
Language.find_or_create_by(name: 'Karelian').countries << [fi]
Language.find_or_create_by(name: 'Kashub').countries << [pl]
Language.find_or_create_by(name: 'Krimchak').countries << [ua]
Language.find_or_create_by(name: 'Kurdish').countries << [am]
Language.find_or_create_by(name: 'Kven/Finnish').countries << [no]
Language.find_or_create_by(name: 'Ladino').countries << [ba]
Language.find_or_create_by(name: 'Lemko').countries << [pl]
Language.find_or_create_by(name: 'Leonese').countries << [es]
Language.find_or_create_by(name: 'Limburgish').countries << [nl]
Language.find_or_create_by(name: 'Lithuanian').countries << [pl]
Language.find_or_create_by(name: 'Low German').countries << [de]
Language.find_or_create_by(name: 'Lower Saxon').countries << [nl]
Language.find_or_create_by(name: 'Lower Sorbian').countries << [de]
Language.find_or_create_by(name: 'Lule Sami').countries << [no, se]
Language.find_or_create_by(name: 'Macedonian').countries << [ba, ro, rs]
Language.find_or_create_by(name: 'Manx Gaelic').countries << [gb]
Language.find_or_create_by(name: 'Meänkieli').countries << [se]
Language.find_or_create_by(name: 'Moldovan').countries << [ua]
Language.find_or_create_by(name: 'Montenegrin').countries << [ba]
Language.find_or_create_by(name: 'North Frisian').countries << [de]
Language.find_or_create_by(name: 'North Sami').countries << [fi, no, se]
Language.find_or_create_by(name: 'Polish').countries << [ba, cz, hu, ro, sk, ua]
Language.find_or_create_by(name: 'Romani').countries << [at, ba, cz, fi, de, hu, me, nl, no, pl, ro, rs, sk, si, se, ua]
Language.find_or_create_by(name: 'Romanian').countries << [ba, hr, hu, rs, ua]
Language.find_or_create_by(name: 'Romansh').countries << [ch]
Language.find_or_create_by(name: 'Russian').countries << [am, fi, pl, ro, ua]
Language.find_or_create_by(name: 'Ruthenian').countries << [ba, hr, hu, ro, rs, sk, ua]
Language.find_or_create_by(name: 'Sater Frisian').countries << [de]
Language.find_or_create_by(name: 'Scots').countries << [gb]
Language.find_or_create_by(name: 'Scottish-Gaelic').countries << [gb]
Language.find_or_create_by(name: 'Serbian').countries << [hr, hu, ro, si]
Language.find_or_create_by(name: 'Skolt Sami Eastern').countries << [fi, no]
Language.find_or_create_by(name: 'Slovakian').countries << [at, ba, hr, cz, hu, pl, ro, rs, ua]
Language.find_or_create_by(name: 'Slovenian').countries << [at, ba, hr, hu]
Language.find_or_create_by(name: 'South Sami').countries << [no, se]
Language.find_or_create_by(name: 'Swedish').countries << [fi]
Language.find_or_create_by(name: 'Tatar').countries << [fi, pl, ro]
Language.find_or_create_by(name: 'Turkish').countries << [ba, ro]
Language.find_or_create_by(name: 'Ukrainian').countries << [am, ba, hr, hu, pl, ro, rs, sk]
Language.find_or_create_by(name: 'Ulster Scots').countries << [gb]
Language.find_or_create_by(name: 'Upper Sorbian').countries << [de]
Language.find_or_create_by(name: 'Valencian').countries << [es]
Language.find_or_create_by(name: 'Vlach').countries << [rs]
Language.find_or_create_by(name: 'Welsh').countries << [gb]
Language.find_or_create_by(name: 'Yenish').countries << [ch]
Language.find_or_create_by(name: 'Yezidi').countries << [am]
Language.find_or_create_by(name: 'Yiddish').countries << [ba, fi, nl, pl, ro, sk, se, ua]
