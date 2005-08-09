CREATE TABLE jobs2_feeds 
(
    relevance varchar(80), 
    format varchar(80),
    xmltext mediumblob
);
CREATE UNIQUE INDEX jobs2_feeds_index ON jobs2_feeds (relevance, format);
INSERT INTO jobs2_feeds (relevance, format, xmltext) VALUES ('all', 'rss', '');
