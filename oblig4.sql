-- Oppgave 2a)
CREATE TABLE kunde_ny(
    knr INTEGER PRIMARY KEY,
    kunde_xml XML
);

-- Oppgave 2c)
INSERT INTO kunde_ny(knr, kunde_xml)
SELECT k.knr, XMLElement(name "kunde",
              XMLelement(name "fornavn", k.fornavn),
              XMLElement(name "etternavn", k.etternavn),
              XMLElement(name "adresse", k.adresse),
              XMLElement(name "postnr", k.postnr)
              )
FROM kunde AS k;

-- Oppgave 2e)
SELECT k.knr,
       XPath('/kunde/fornavn/text()', kunde_xml) navn,
       XPath('/kunde/adresse/text()', kunde_xml) adresse,
       XPath('/kunde/postnr/text()', kunde_xml) postnr
FROM kunde AS k;