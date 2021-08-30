CREATE TABLE IF NOT EXISTS `velhomyyjat` (
  `npc` int(2) DEFAULT NULL,
  `jaljella` int(3) DEFAULT NULL,
  `kaytossa` int(1) DEFAULT NULL,
  `tuotot` int(5) DEFAULT NULL,
  `x` double DEFAULT NULL,
  `y` double DEFAULT NULL,
  `z` double DEFAULT NULL,
  `h` int(11) DEFAULT NULL,
  `tyyppi` varchar(50) DEFAULT NULL,
  `tavara` varchar(50) DEFAULT NULL,
  `label` varchar(50) DEFAULT NULL,
  `hinta` int(5) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--example
/*!40000 ALTER TABLE `velhomyyjat` DISABLE KEYS */;
INSERT IGNORE INTO `velhomyyjat` (`npc`, `jaljella`, `kaytossa`, `tuotot`, `x`, `y`, `z`, `h`, `tyyppi`, `tavara`, `label`, `hinta`) VALUES
	(1, 3, 1, 0, 135.99000549316406, -57.11000061035156, 67.66999816894531, 67, 'ASE', 'WEAPON_PISTOL50', 'PISTOL.50', 10000),
	(2, 3, 1, 0, 133.6199951171875, -64.12999725341797, 67.66999816894531, 67, 'ITEMI', 'luotiliivi', 'LUOTTARIT', 500);
