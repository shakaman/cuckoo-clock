# Coucou LEGO — boîtier & mécanique v0.2 (style moderne)

Source paramétrique : `coucou.scad` (OpenSCAD). STL dans `stl/`, déjà orientés pour l'impression.
Encombrement : **200 × 115 × 290 mm** (210 mm au toit, cheminée et contrepoids en plus). Toutes les pièces tiennent sur un plateau de 250 mm.
`style = "classic"` dans le .scad redonne la version chalet (tuiles, chiffres, cœur, planches).

Visuels : `../docs/img/rendu_3d.png` (vue + coupe), `../docs/img/face_avant_moderne.png`, `../docs/plan_face_avant_1-1.pdf` (gabarit à taille réelle).

## Design
- Façade crème à arêtes avant arrondies (R8), toit noyer épais (6 mm) sans tuiles, pente 45°.
- Cadran anthracite Ø80 avec index blancs sans chiffres (impression bicolore), couleur d'accent orange (cheminée-bouton, trotteuse, contrepoids en gélule).
- 2 écrans ronds en guise d'yeux, entraxe 124 mm.
- 5 interrupteurs L-V en bas, avec la LED du jour à droite de chacun.

## Mécanique
- **Porte guillotine** levée par un servo logé dans le pignon (bras + biellette). Pente mini 45° pour le débattement du bras.
- **Chariot sur glissière**, poussé par crémaillère + pignon 25 dents : 180° de servo = **39,3 mm** de course.
- **Plateau tournant** au bout d'un bras qui passe la porte : servo embarqué + 2 engrenages 30 dents (1:1). Plaque LEGO 2×2 collée sur l'engrenage.
- **Radar de présence LD2410C** caché derrière la façade, à gauche du cadran (glissière moulée, la carte s'insère par le haut, antenne contre la façade). Aucun perçage : les 24 GHz traversent 4 mm de PLA/PETG.

## Impression (PETG conseillé pour la mécanique)
| Pièce | Notes |
|---|---|
| body | face avant sur le plateau ; lettres L-V gravées |
| carriage | supports sous le bras |
| roof_right / roof_left | à plat, face intérieure dessous |
| dial | changement de filament à 2 mm pour les index ; logement du capteur Hall au dos, à midi (r = 28 mm), rainure de fils vers le trou de façade |
| engrenages, porte, rails | couche 0,12-0,16 mm, 100 % de remplissage pour les engrenages |

## Visserie
- Inserts laiton M3 (env. 30) + vis M3×8/10 ; vis M3 tête basse + écrou frein pour l'axe du plateau
- Vis M2 + écrous (servos, biellette de porte)
- Mouvement quartz **pas à pas** à axe long (façade 4 mm + cadran 2 mm), modifié pour être piloté par l'ESP32
- Aimant néodyme Ø3×2 (sous l'aiguille des minutes) + capteur Hall DRV5032 SOT-23

## Électronique — changements v0.2
- **Supprimé** : PN532 + tags NFC (la figurine n'est plus reconnue automatiquement ; le son/l'animation se choisissent sur la page web).
- **Ajouté** : radar LD2410C (~4 €), 5 V, UART 256000 bauds.
  - ESP32-S3 : LD2410C TX → GPIO 39, RX ← GPIO 40, OUT → GPIO 41.

## Impact firmware
| Servo | Rôle | Plage |
|---|---|---|
| porte | bras bas (90°) = fermé → bras haut (-90°) = ouvert | 180° |
| crémaillère | 0° = rentré, 180° = sorti | 39,3 mm |
| rotation | figurine, 1:1 | ±90° autour de « face » |

- Séquence coucou : porte ouverte → chariot sort → rotation/son/yeux → rotation 0° → chariot rentre → porte fermée.
- Radar : utiliser la cible **en mouvement** et sa distance (UART) pour réveiller les yeux seulement si quelqu'un passe à moins d'~1,5 m. Désactivé en mode nuit, temporisation avant extinction.

## À mesurer avant impression
Section « Composants » du .scad : servos MG90S (hauteurs), Ø du PCB des GC9A01, LD2410C (16 × 22 mm), mouvement quartz.
