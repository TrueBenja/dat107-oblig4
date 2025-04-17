SET search_path TO oblig4;

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
    CONCAT(UNNEST(XPath('/kunde/fornavn/text()', k.kunde_xml)), ' ', UNNEST(XPath('/kunde/etternavn/text()', k.kunde_xml))) navn,
    UNNEST(XPath('/kunde/adresse/text()', k.kunde_xml))::text adresse,
    UNNEST(XPath('/kunde/postnr/text()', k.kunde_xml))::text postnr
FROM kunde_ny AS k;

-- Oppgave 2f)
SELECT k.knr,
    CONCAT(UNNEST(XPath('/kunde/fornavn/text()', k.kunde_xml)), ' ', UNNEST(XPath('/kunde/etternavn/text()', k.kunde_xml))) navn,
    UNNEST(XPath('/kunde/adresse/text()', k.kunde_xml))::text adresse,
    UNNEST(XPath('/kunde/postnr/text()', k.kunde_xml))::text postnr
FROM kunde_ny AS k
WHERE xpath_exists('/kunde[starts-with(//etternavn/text(), "A")]', k.kunde_xml)
ORDER BY UNNEST(XPath('/kunde/etternavn/text()', k.kunde_xml))::text;

-- Oppgave 2g)
CREATE TABLE ordre_ny(
    ordrenr INTEGER PRIMARY KEY,
    kundenr INTEGER,
    ordre_xml XML,
    FOREIGN KEY (kundenr) REFERENCES kunde_ny
);

-- Oppgave 2i)
INSERT INTO ordre_ny(ordrenr, kundenr, ordre_xml)
SELECT o.ordrenr, o.knr, XMLElement(name "ordre",
                         XMLElement(name "ordredato", o.ordredato),
                         XMLElement(name "sendtdato", o.sendtdato),
                         XMLElement(name "betaltdato", o.betaltdato)
                         )
FROM ordre AS o;