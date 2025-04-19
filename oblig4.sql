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

-- Oppgave 2k)
INSERT INTO ordre_ny(ordrenr, kundenr, ordre_xml)
SELECT o.ordrenr, o.knr, XMLElement(name "ordre",
        XMLElement(name "ordredato", o.ordredato),
        XMLElement(name "sendtdato", o.sendtdato),
        XMLElement(name "betaltdato", o.betaltdato),
        ol_xml.ordrelinjer)
FROM ordre AS o LEFT JOIN
(
SELECT ol.ordrenr, XMLElement(name "ordrelinjer",
        xmlagg(XMLElement(name "ordrelinje",
            XMLElement(name "vnr", ol.vnr),
            XMLElement(name "prisprenhet", ol.prisprenhet),
            XMLElement(name "antall", ol.antall))))
AS ordrelinjer
FROM ordrelinje as ol GROUP BY ol.ordrenr
) AS ol_xml ON o.ordrenr = ol_xml.ordrenr;

-- Oppgave 2m)
SELECT ordrenr, kundenr,
        UNNEST(XPath('//vnr/text()', ordre_xml))::text::integer vnr,
        UNNEST(XPath('//prisprenhet/text()', ordre_xml))::text::float prisprenhet,
        UNNEST(XPath('//antall/text()', ordre_xml))::text::integer antall
FROM ordre_ny
WHERE kundenr = 5643
AND (XPath('//sendtdato/text()', ordre_xml))[1]::text::date >= '2019-08-01'::date
AND (XPath('//sendtdato/text()', ordre_xml))[1]::text::date <= '2019-08-31'::date;