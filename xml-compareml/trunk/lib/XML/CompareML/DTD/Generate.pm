package XML::CompareML::DTD::Generate;

use strict;
use warnings;

sub get_dtd
{
    return <<"EOF";
<!ELEMENT comparison (meta,contents)>
<!ELEMENT meta (implementations,timestamp?)>
<!ELEMENT implementations (impl+)>
<!ELEMENT impl (name)>
<!ELEMENT name (#PCDATA)>
<!ELEMENT contents (section)>
<!ELEMENT section (title,expl?,compare?,section*)>
<!ELEMENT title (#PCDATA)>
<!ELEMENT expl (#PCDATA)>
<!ELEMENT compare (s+)>
<!ELEMENT s (#PCDATA|a)*>
<!ELEMENT a (#PCDATA)>
<!ELEMENT timestamp (#PCDATA)>
<!ATTLIST section id ID #REQUIRED>
<!ATTLIST a href CDATA #REQUIRED>
<!ATTLIST s id CDATA #REQUIRED>
<!ATTLIST impl id CDATA #REQUIRED>    
EOF
}
1;
