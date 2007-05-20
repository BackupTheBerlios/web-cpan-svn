CREATE TABLE `consultants2_feeds` (
  `relevance` varchar(80) default NULL,
  `format` varchar(80) default NULL,
  `xmltext` mediumblob,
  UNIQUE KEY `jobs2_feeds_index` (`relevance`,`format`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
