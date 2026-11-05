# Charte graphique — Cockpit

| Information | Valeur |
| --- | --- |
| Version | 0.1 |
| Date | 3 septembre 2026 |
| Direction | Signal |
| Périmètre | Interface interne et portail client de la V1 |

## 1. Intention

Cockpit doit inspirer la maîtrise, la clarté et la confiance. L’identité « Signal » traduit le pilotage d’une mission sans reprendre l’accumulation visuelle des plateformes généralistes. Elle privilégie une interface calme, structurée et suffisamment dense pour le travail quotidien d’une petite ESN.

Trois principes orientent les interfaces :

- rendre immédiatement visibles l’état d’une mission et les actions attendues ;
- distinguer clairement l’espace de travail interne du portail client ;
- ne jamais transmettre une information uniquement par la couleur.

## 2. Nom et expression de marque

Le produit s’appelle **Cockpit**.

La signature recommandée est : **« Vos missions, clairement. »**

Le ton éditorial est direct, rassurant et professionnel. Les libellés utilisent des verbes précis, par exemple `Soumettre à validation`, `Valider le livrable` et `Demander une révision`. Le vocabulaire technique et les formulations promotionnelles sont évités dans l’interface.

### Piste de symbole

Le symbole associe un `C` ouvert à un cadran de progression. Sa forme doit rester reconnaissable en monochrome et à une taille de 24 pixels. Le mot-symbole `Cockpit` reste lisible sans le pictogramme.

## 3. Palette principale

| Token | Couleur | Usage |
| --- | --- | --- |
| `color-brand-900` | `#0F172A` | navigation principale, titres forts |
| `color-brand-700` | `#0F766E` | actions principales, liens importants |
| `color-brand-100` | `#CCFBF1` | sélection et mise en évidence légère |
| `color-neutral-950` | `#111827` | texte principal |
| `color-neutral-600` | `#475569` | texte secondaire |
| `color-neutral-300` | `#CBD5E1` | bordures et séparateurs |
| `color-neutral-50` | `#F8FAFC` | fond général |
| `color-surface` | `#FFFFFF` | cartes, panneaux et boîtes de dialogue |
| `color-focus` | `#2563EB` | indicateur de focus visible |

Le turquoise clair est réservé aux surfaces et aux éléments décoratifs. Il ne sert pas de couleur de texte sur fond clair.

## 4. Couleurs sémantiques

| État | Texte et icône | Fond | Libellé recommandé |
| --- | --- | --- | --- |
| Information | `#1D4ED8` | `#DBEAFE` | Information |
| Succès | `#166534` | `#DCFCE7` | Validé |
| Attention | `#92400E` | `#FEF3C7` | À valider |
| Erreur | `#B91C1C` | `#FEE2E2` | À réviser |

Chaque badge associe une couleur, une icône et un libellé. Un changement d’état reste donc compréhensible en niveaux de gris ou sans perception des couleurs.

## 5. Contrastes vérifiés

Les rapports suivants ont été calculés selon la méthode WCAG utilisée par le RGAA 4.1.2 :

| Combinaison | Rapport |
| --- | ---: |
| blanc sur turquoise principal | `5,47:1` |
| texte principal sur fond général | `16,96:1` |
| texte secondaire sur fond général | `7,24:1` |
| indicateur de focus sur fond général | `4,94:1` |
| succès sur son fond | `6,49:1` |
| attention sur son fond | `6,37:1` |
| erreur sur son fond | `5,30:1` |
| information sur son fond | `5,49:1` |

Ces combinaisons dépassent le rapport de `4,5:1` prévu pour le texte courant. Les composants, bordures porteuses d’information et états de focus visent au minimum `3:1` avec les couleurs adjacentes.

## 6. Typographie

La famille principale est **Inter Variable**, distribuée avec l’application afin de ne pas dépendre d’un CDN. Les polices système `system-ui`, `-apple-system`, `BlinkMacSystemFont` et `sans-serif` constituent la pile de repli.

| Token | Taille / interligne | Graisse | Usage |
| --- | --- | --- | --- |
| `text-display` | `32 / 40 px` | 700 | titre d’un tableau de bord |
| `text-heading-1` | `24 / 32 px` | 700 | titre de page |
| `text-heading-2` | `20 / 28 px` | 600 | titre de section |
| `text-heading-3` | `16 / 24 px` | 600 | titre de carte |
| `text-body` | `16 / 24 px` | 400 | contenu courant |
| `text-body-small` | `14 / 20 px` | 400 | métadonnées |
| `text-label` | `14 / 20 px` | 600 | boutons et champs |

Le texte courant ne descend pas sous 14 pixels. Les intitulés fonctionnels ne sont pas écrits intégralement en capitales.

## 7. Grille, espaces et formes

L’espacement repose sur une unité de 4 pixels :

| Token | Valeur |
| --- | ---: |
| `space-1` | `4 px` |
| `space-2` | `8 px` |
| `space-3` | `12 px` |
| `space-4` | `16 px` |
| `space-6` | `24 px` |
| `space-8` | `32 px` |
| `space-12` | `48 px` |

Les cartes utilisent un rayon de `12 px`, les champs et boutons `8 px`, et les badges un rayon complet. Les ombres restent discrètes ; une bordure visible structure prioritairement les surfaces.

La largeur de lecture du portail client est limitée à environ `1120 px`. Le Kanban interne peut occuper toute la largeur disponible afin de préserver la visibilité des colonnes.

## 8. Composants et interactions

- La hauteur minimale des cibles interactives est de `44 px` sur les parcours principaux.
- Le bouton principal utilise le turquoise `#0F766E` avec un texte blanc.
- Une seule action principale est mise en avant par zone.
- Les actions destructives ou engageantes demandent une confirmation explicite.
- Le focus clavier utilise un contour bleu de `2 px` avec un décalage de `2 px`.
- Les animations fonctionnelles durent de `120` à `200 ms` et respectent la préférence de réduction des mouvements.
- Les états chargement, vide, erreur, succès, accès refusé et données obsolètes sont prévus pour chaque écran concerné.

## 9. Différenciation des deux espaces

### Espace interne

L’espace de l’équipe privilégie la densité et l’efficacité : navigation latérale, raccourcis clavier, Kanban horizontal et métadonnées compactes. Les tâches, estimations et informations internes y sont visibles selon les permissions.

### Portail client

Le portail client privilégie la compréhension : progression de la mission, échéances, livrables et actions de validation. Il ne reprend ni le Kanban interne ni ses données. Les décisions `Valider` et `Demander une révision` sont présentées sans ambiguïté.

## 10. Accessibilité des futures maquettes

Les maquettes et le prototype doivent documenter :

- l’ordre de tabulation et le focus visible ;
- les intitulés accessibles des boutons comportant uniquement une icône ;
- les textes alternatifs des images informatives ;
- les erreurs de formulaire associées à leurs champs ;
- l’état courant des onglets, menus et éléments sélectionnés ;
- une alternative textuelle à toute progression graphique ;
- le comportement à un zoom de 200 % et aux largeurs mobiles ;
- l’absence de gestes complexes obligatoires.

La conformité ne pourra être déclarée qu’après contrôle des maquettes puis de l’interface implémentée. La charte établit les conditions graphiques initiales, mais ne constitue pas à elle seule un audit RGAA.

## 11. Répartition des livrables

La présente charte fournit les couleurs, la typographie, les tokens et les règles d’accessibilité de référence. Le porteur de projet réalise dans Figma les wireframes, les maquettes haute fidélité et le prototype interactif du parcours principal en appliquant ces règles.

## 12. Référence d’accessibilité

- [RGAA 4.1.2 — critères et tests](https://accessibilite.numerique.gouv.fr/methode/criteres-et-tests/)
