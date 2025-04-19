SET search_path TO oblig4;

-- Oppgave 2 a)
CREATE TABLE kunde_ny(
    knr INTEGER PRIMARY KEY,
    kunde_xml XML
);

-- Oppgave 2 c)
INSERT INTO kunde_ny(knr, kunde_xml)
SELECT k.knr, XMLElement(name "kunde",
              XMLelement(name "fornavn", k.fornavn),
              XMLElement(name "etternavn", k.etternavn),
              XMLElement(name "adresse", k.adresse),
              XMLElement(name "postnr", k.postnr)
              )
FROM kunde AS k;

-- Oppgave 2 e)
SELECT k.knr,
    CONCAT(UNNEST(XPath('/kunde/fornavn/text()', k.kunde_xml)), ' ', UNNEST(XPath('/kunde/etternavn/text()', k.kunde_xml))) navn,
    UNNEST(XPath('/kunde/adresse/text()', k.kunde_xml))::text adresse,
    UNNEST(XPath('/kunde/postnr/text()', k.kunde_xml))::text postnr
FROM kunde_ny AS k;

-- Oppgave 2 f)
SELECT k.knr,
    CONCAT(UNNEST(XPath('/kunde/fornavn/text()', k.kunde_xml)), ' ', UNNEST(XPath('/kunde/etternavn/text()', k.kunde_xml))) navn,
    UNNEST(XPath('/kunde/adresse/text()', k.kunde_xml))::text adresse,
    UNNEST(XPath('/kunde/postnr/text()', k.kunde_xml))::text postnr
FROM kunde_ny AS k
WHERE xpath_exists('/kunde[starts-with(//etternavn/text(), "A")]', k.kunde_xml)
ORDER BY UNNEST(XPath('/kunde/etternavn/text()', k.kunde_xml))::text;

-- Oppgave 2 g)
CREATE TABLE ordre_ny(
    ordrenr INTEGER PRIMARY KEY,
    kundenr INTEGER,
    ordre_xml XML,
    FOREIGN KEY (kundenr) REFERENCES kunde_ny
);

-- Oppgave 2 i)
INSERT INTO ordre_ny(ordrenr, kundenr, ordre_xml)
SELECT o.ordrenr, o.knr, XMLElement(name "ordre",
                         XMLElement(name "ordredato", o.ordredato),
                         XMLElement(name "sendtdato", o.sendtdato),
                         XMLElement(name "betaltdato", o.betaltdato)
                         )
FROM ordre AS o;

-- Oppgave 2 k)
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

-- Oppgave 2 m)
SELECT ordrenr, kundenr,
        UNNEST(XPath('//vnr/text()', ordre_xml))::text::integer vnr,
        UNNEST(XPath('//prisprenhet/text()', ordre_xml))::text::float prisprenhet,
        UNNEST(XPath('//antall/text()', ordre_xml))::text::integer antall
FROM ordre_ny
WHERE kundenr = 5643
AND (XPath('//sendtdato/text()', ordre_xml))[1]::text::date >= '2019-08-01'::date
AND (XPath('//sendtdato/text()', ordre_xml))[1]::text::date <= '2019-08-31'::date;

-- Oppgave 3 b)

-- Kunde
SELECT json_build_object('knr', k.knr, 'fornavn', k.fornavn, 'etternavn', k.etternavn,
    'adresse', k.adresse, 'postnr', k.postnr, 'poststed', ps.poststed)
FROM kunde AS k INNER JOIN
poststed as ps on k.postnr = ps.postnr;

-- Vare
SELECT json_build_object('vnr', v.vnr, 'betegnelse', v.betegnelse, 'pris', v.pris,
    'kategori', k.navn, 'antall', v.antall, 'hylle', v.hylle)
FROM vare AS v INNER JOIN
    kategori AS k ON v.katnr = k.katnr;

-- Ordre
SELECT json_build_object('ordrenr', o.ordrenr, 'ordredato', o.ordredato, 'sendtdato', o.sendtdato,
    'betaltdato', o.betaltdato, 'knr', o.knr, 'ordrelinjer', ol_json.ordrelinjer)
FROM ordre AS o INNER JOIN
(
    SELECT json_agg(json_build_object('vnr', ol.vnr, 'prisprenhet',
                          ol.prisprenhet,'antall', ol.antall)) ordrelinjer, ol.ordrenr
    FROM ordrelinje AS ol
    GROUP BY ol.ordrenr
) AS ol_json
ON ol_json.ordrenr = o.ordrenr;