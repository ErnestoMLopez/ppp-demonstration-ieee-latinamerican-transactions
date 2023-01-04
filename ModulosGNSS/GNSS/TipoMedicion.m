% Clase para los diferentes tipos de mediciones. Se utilizan los códigos del
% formato RINEX 3.0

classdef TipoMedicion < uint32
	enumeration
		UNKNOWN_MED  (0) 							% N/A
		C1A ( 1),  L1A ( 2),  D1A ( 3),  S1A ( 4)	% GAL			A PRS			@ E1
		C1B ( 5),  L1B ( 6),  D1B ( 7),  S1B ( 8)	% GAL			B I/NAV			@ E1
		C1C ( 9),  L1C (10),  D1C (11),  S1C (12)	% GP/GL/GA/SB/QZC/A				@ L1/G1/E1
		C1L (13),  L1L (14),  D1L (15),  S1L (16)	% GP/QZ			L1C (P)			@ L1
		C1P (17),  L1P (18),  D1P (19),  S1P (20)	% GP/GL			P				@ L1/G1
		C1S (21),  L1S (22),  D1S (23),  S1S (24)	% GP/QZ			L1C (D)			@ L1
		C1W (25),  L1W (26),  D1W (27),  S1W (28)	% GPS			Z				@ L1
		C1I (29),  L1I (30),  D1I (31),  S1I (32)	% BDS			I				@ B1
		C1Q (33),  L1Q (34),  D1Q (35),  S1Q (36)	% BDS			Q				@ B1
		C1X (37),  L1X (38),  D1X (39),  S1X (40)	% GP/QZ/GA/BD	L1C(D+P)/B+C/I+Q@ L1/E1/B1
		C1Y (41),  L1Y (42),  D1Y (43),  S1Y (44)	% GPS			Y				@ L1
		C1Z (45),  L1Z (46),  D1Z (47),  S1Z (48)	% GP/GA/QZ		Z/A+B+C/SAIF	@ L1/E1
		C1M (49),  L1M (50),  D1M (51),  S1M (52)	% GPS			M				@ L1
		           L1N (53),  D1N (54),  S1N (55)	% GPS			codeless		@ L1
		...		  
		C2C (56),  L2C (57),  D2C (58),  S2C (59)	% GP/GL			C/A				@ L2/G2
		C2D (60),  L2D (61),  D2D (62),  S2D (63)	% GPS			L1(C/A)+(P2-P1)	@ L2
		C2S (64),  L2S (65),  D2S (66),  S2S (67)	% GP/QZ			L2C (M)			@ L2
		C2L (68),  L2L (69),  D2L (70),  S2L (71)	% GP/QZ			L2C (L)			@ L2
		C2X (72),  L2X (73),  D2X (74),  S2X (75)	% GP/QZ			L2C (M+L)		@ L2
		C2P (76),  L2P (77),  D2P (78),  S2P (79)	% GP/GL			P				@ L2/G2
		C2W (80),  L2W (81),  D2W (82),  S2W (83)	% GPS			Z				@ L2
		C2Y (84),  L2Y (85),  D2Y (86),  S2Y (87)	% GPS			Y				@ L2
		C2M (88),  L2M (89),  D2M (90),  S2M (91)	% GPS			M				@ L2
		           L2N (92),  D2N (93),  S2N (94)	% GPS			codeless		@ L2
		...
		C3I (95),  L3I (96),  D3I (97),  S3I (98)	% GL			I				@ G3
		C3Q (99),  L3Q (100), D3Q (101), S3Q (102)	% GL			Q				@ G3
		C3X (103), L3X (104), D3X (105), S3X (106)	% GL			I+Q				@ G3		
		...
		C5A (107), L5A (108), D5A (109), S5A (110)	% IRN			A SPS			@ L5
		C5B (111), L5B (112), D5B (113), S5B (114)	% IRN			B RS			@ L5
		C5C (115), L5C (116), D5C (117), S5C (118)	% IRN			C RS			@ L5
		C5I (119), L5I (120), D5I (121), S5I (122)	% GP/GA/SB/QZ	I				@ L5/E5a
		C5Q (123), L5Q (124), D5Q (125), S5Q (126)	% GP/GA/SB/QZ	Q				@ L5/E5a
		C5X (127), L5X (128), D5X (129), S5X (130)	% GP/GA/SB/QZ/IRI+Q/B+C			@ L5/E5a
		...
		C6I (131), L6I (132), D6I (133), S6I (134)	% BDS			I				@ B3
		C6Q (135), L6Q (136), D6Q (137), S6Q (138)	% BDS			Q				@ B3
		C6A (139), L6A (140), D6A (141), S6A (142)	% GAL			A PRS			@ E6
		C6B (143), L6B (144), D6B (145), S6B (146)	% GAL			B C/NAV			@ E6
		C6C (147), L6C (148), D6C (149), S6C (150)	% GAL			C				@ E6
		C6S (151), L6S (152), D6S (153), S6S (154)	% GA/QZ			C/S				@ E6/LEX6
		C6L (155), L6L (156), D6L (157), S6L (158)	% GA/QZ			C/L				@ E6/LEX6
		C6X (159), L6X (160), D6X (161), S6X (162)	% GA/QZ/BD		B+C/S+L			@ E6/LEX6/B3
		C6Z (163), L6Z (164), D6Z (165), S6Z (166)	% GAL			A+B+C			@ E6
		...
		C7I (167), L7I (168), D7I (169), S7I (170)	% GA/BD			I				@ E5b/B2
		C7Q (171), L7Q (172), D7Q (173), S7Q (174)	% GA/BD			Q				@ E5b/B2
		C7X (175), L7X (176), D7X (177), S7X (178)	% GA/BD			I+Q				@ E5b/B2
		...
		C8I (179), L8I (180), D8I (181), S8I (182)	% GAL			I				@ E5 (E5a+E5b)
		C8Q (183), L8Q (184), D8Q (185), S8Q (186)	% GAL			Q				@ E5 (E5a+E5b)
		C8X (187), L8X (188), D8X (189), S8X (190)	% GAL			I+Q				@ E5 (E5a+E5b)
		...
		C9A (191), L9A (192), D9A (193), S9A (194)	% IRN			A SPS			@ S
		C9B (195), L9B (196), D9B (197), S9B (198)	% IRN			B RS			@ S
		C9C (199), L9C (200), D9C (201), S9C (202)	% IRN			C RS			@ S
		C9X (203), L9X (204), D9X (205), S9X (206)	% IRN			B+C				@ S
		...
		% Combinaciones
		FIN_OBS (207)
		PNL (208)	% GPS	Combinación narrow-lane de pseudorangos				(f1*P1+f2*P2)/(f1+f2)
		LNL (209)	% GPS	Combinación narrow-lane de fases de portadora		(f1*L1+f2*L2)/(f1+f2)
		PWL (210)	% GPS	Combinación wide-lane de pseudorangos				(f1*P1-f2*P2)/(f1-f2)
		LWL (211)	% GPS	Combinación wide-lane de fases de portadora			(f1*L1-f2*L2)/(f1-f2)
		MWC (212)	% GPS	Combinación Melbourne-Wübbena						(LWL-PNL)
		PGF (213)	% GPS	Combinación libre de geometría de pseudorangos		(P1-P2) o (C1-C2)
		LGF (214)	% GPS	Combinación libre de geometría de fases	de portadora(L1-L2)
		PIF (215)	% GPS	Combinación libre de ionósfera de pseudorangos		(f1^2*P1-f2^2*P2)/(f1^2-f2^2)
		LIF (216)	% GPS	Combinación libre de ionósfera de fases de portadora(f1^2*L1-f2^2*L2)/(f1^2-f2^2)
		PCIF (217)	% GPS	Combinación libre de ionósfera de pseudorangos		(f1^2*C1-f2^2*P2)/(f1^2-f2^2)
		G1C (218)	% GPS	Combinación GRAPHIC entre C1 y L1					(C1+L1)/2
		G1P (219)	% GPS	Combinación GRAPHIC entre P1 y L1					(P1+L1)/2
		G2C (220)	% GPS	Combinación GRAPHIC entre C2 y L2					(C2+L2)/2
		G2P (221)	% GPS	Combinación GRAPHIC entre P2 y L2					(P2+L2)/2
		LDF (222)	% GPS	Combinación libre de divergencia de fases			(L1 + 2/((f1/f2)^2-1)*(L1-L2))
		MP1P (223)	% GPS	Combinación de multicamino para L1 con P1			P1 - (f1^2+f2^2)/(f1^2-f2^2)*L1 + (2f2^2)/(f1^2-f2^2)*L2
		MP2P (224)	% GPS	Combinación de multicamino para L2 con P2			P2 - (2f1^2)/(f1^2-f2^2)*L1 + (f1^2+f2^2)/(f1^2-f2^2)*L2
		MP1C (223)	% GPS	Combinación de multicamino para L1 con C1			C1 - (f1^2+f2^2)/(f1^2-f2^2)*L1 + (2f2^2)/(f1^2-f2^2)*L2
		MP2C (224)	% GPS	Combinación de multicamino para L2 con C2			C2 - (2f1^2)/(f1^2-f2^2)*L1 + (f1^2+f2^2)/(f1^2-f2^2)*L2
		
	end
end