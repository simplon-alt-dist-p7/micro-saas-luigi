# Spécifications fonctionnelles — Suivi et validation des livrables

| Information | Valeur |
| --- | --- |
| Version | 0.1 |
| Date | 2 septembre 2026 |
| Statut | Spécifications de la V1 |
| Epic | #41 — Spécifications & architecture |

## 1. Objet

La V1 fournit à une petite ESN ou agence numérique un espace commun pour suivre une mission client et faire valider ses livrables. L’équipe conserve un Kanban interne. Le client accède à une vue limitée aux informations qui lui sont destinées.

Ces spécifications décrivent des comportements métier observables. Elles ne prescrivent ni écran précis ni enchaînement de clics.

## 2. Acteurs

- **Administrateur :** gère l’organisation, ses utilisateurs et ses clients.
- **Chef de projet :** crée les missions et livrables, organise le travail interne et soumet les livrables.
- **Collaborateur :** consulte et met à jour les tâches internes auxquelles il est autorisé à accéder.
- **Client invité :** consulte uniquement les missions auxquelles il est rattaché et répond aux demandes de validation.

## 3. Vocabulaire métier

### Statuts d’une tâche interne

- `À faire`
- `En cours`
- `Terminé`

### Statuts d’un livrable

- `Brouillon` : le livrable est préparé par l’équipe.
- `À valider` : le chef de projet attend une décision du client.
- `À réviser` : le client a demandé une correction motivée.
- `Validé` : le client a accepté le livrable.

### Progression d’une mission

La progression visible par le client est le nombre de livrables au statut `Validé` divisé par le nombre total de livrables prévus. Une mission sans livrable affiche une progression de 0 %.

## 4. User Stories et scénarios Gherkin

Les scénarios utilisent la syntaxe française officielle de Gherkin : `Étant donné`, `Quand`, `Alors` correspondent à `Given`, `When`, `Then`.

### US1 — Créer une mission et ses livrables (#8)

> En tant que chef de projet, je veux créer une mission et ses livrables, afin de structurer le suivi client.

```gherkin
# language: fr
Fonctionnalité: Création d’une mission client

  Scénario: Créer une mission comportant des livrables
    Étant donné un chef de projet authentifié dans une organisation
    Et un client enregistré dans cette organisation
    Quand il crée une mission comportant au moins un livrable
    Alors la mission et ses livrables sont rattachés au client et à l’organisation
    Et ils sont accessibles uniquement aux membres autorisés
    Et la progression initiale de la mission est de 0 %

  Scénario: Refuser la création d’une mission sans livrable
    Étant donné un chef de projet authentifié dans une organisation
    Quand il tente de créer une mission sans livrable
    Alors la création est refusée
    Et aucune mission incomplète n’est enregistrée
```

### US2 — Mettre à jour les tâches internes (#6)

> En tant que collaborateur, je veux mettre à jour mes tâches internes, afin de refléter l’avancement réel de la mission.

```gherkin
# language: fr
Fonctionnalité: Suivi du travail interne

  Scénario: Modifier le statut d’une tâche autorisée
    Étant donné un collaborateur autorisé sur une mission
    Et une tâche interne qui lui est assignée
    Quand il modifie le statut de cette tâche
    Alors le nouveau statut est enregistré dans le Kanban de la mission
    Et la mise à jour est transmise aux membres autorisés
    Mais la tâche reste invisible pour le client

  Scénario: Refuser la modification d’une tâche non autorisée
    Étant donné un collaborateur authentifié
    Et une tâche appartenant à une mission à laquelle il n’a pas accès
    Quand il tente de modifier le statut de cette tâche
    Alors la modification est refusée
    Et le statut de la tâche reste inchangé
```

### US3 — Consulter l’avancement d’une mission (#16)

> En tant que client invité, je veux consulter l’avancement de ma mission, afin de disposer d’une information fiable et actualisée.

```gherkin
# language: fr
Fonctionnalité: Consultation du portail client

  Scénario: Consulter une mission autorisée
    Étant donné un client invité authentifié et rattaché à une mission
    Quand il consulte cette mission dans le portail client
    Alors il voit les livrables, leurs statuts et la progression calculée
    Mais il ne voit ni les tâches internes ni leurs estimations
    Et aucune autre mission ne lui est accessible

  Scénario: Refuser l’accès à une mission non rattachée
    Étant donné un client invité authentifié
    Et une mission à laquelle il n’est pas rattaché
    Quand il tente de consulter cette mission
    Alors l’accès est refusé
    Et aucune information sur la mission n’est révélée
```

### US4 — Valider un livrable (#11)

> En tant que client invité, je veux valider un livrable soumis, afin de confirmer officiellement son acceptation.

```gherkin
# language: fr
Fonctionnalité: Validation d’un livrable

  Scénario: Valider un livrable en attente
    Étant donné un livrable au statut « À valider »
    Et un client invité autorisé sur sa mission
    Quand le client valide ce livrable
    Alors le livrable passe au statut « Validé »
    Et la progression de la mission est recalculée
    Et la décision est ajoutée à l’historique avec son auteur et sa date
    Et l’équipe autorisée reçoit la mise à jour en temps réel

  Scénario: Refuser la validation d’un livrable qui n’est pas en attente
    Étant donné un livrable qui n’est pas au statut « À valider »
    Et un client invité autorisé sur sa mission
    Quand le client tente de valider ce livrable
    Alors la décision est refusée
    Et le statut et la progression restent inchangés
```

### US5 — Demander une révision motivée (#32)

> En tant que client invité, je veux demander la révision d’un livrable avec un motif, afin d’expliquer les corrections attendues.

```gherkin
# language: fr
Fonctionnalité: Demande de révision d’un livrable

  Scénario: Demander une révision avec un motif
    Étant donné un livrable au statut « À valider »
    Et un client invité autorisé sur sa mission
    Quand le client demande une révision avec un motif non vide
    Alors le livrable passe au statut « À réviser »
    Et le motif, son auteur et sa date sont ajoutés à l’historique
    Et l’équipe autorisée reçoit la mise à jour en temps réel

  Scénario: Refuser une demande de révision sans motif
    Étant donné un livrable au statut « À valider »
    Et un client invité autorisé sur sa mission
    Quand le client demande une révision sans motif
    Alors la demande est refusée
    Et le statut du livrable reste inchangé
    Et aucun événement de révision n’est ajouté à l’historique
```

## 5. Règles transverses

```gherkin
# language: fr
Fonctionnalité: Cloisonnement des organisations

  Scénario: Isoler les données de deux organisations
    Étant donné deux utilisateurs authentifiés appartenant à des organisations différentes
    Quand chacun consulte ou modifie une ressource métier
    Alors chacun accède uniquement aux ressources de son organisation
    Et l’identifiant d’une ressource externe ne permet pas de contourner ce cloisonnement

Fonctionnalité: Traçabilité des décisions

  Scénario: Conserver une transition de statut
    Étant donné un utilisateur autorisé qui provoque un changement de statut
    Quand le changement est accepté
    Alors l’état précédent, le nouvel état, l’auteur et la date sont conservés
    Et l’historique existant n’est pas modifié
```

## 6. Exigences non fonctionnelles associées

- Les autorisations sont vérifiées par l’API pour chaque ressource.
- Une transaction garantit la cohérence entre décision, statut, progression et historique.
- Les mises à jour utiles sont diffusées en temps réel sans interrogation fréquente du serveur.
- Les listes sont paginées et ne renvoient que les données nécessaires au rôle courant.
- Les erreurs d’autorisation ne révèlent pas l’existence d’une ressource d’une autre organisation.
- Le parcours principal reste utilisable au clavier et vise la conformité RGAA 4.1.

## 7. Matrice de traçabilité

| User Story | Scénario principal | Cas d’erreur principal | Cas d’utilisation UML |
| --- | --- | --- | --- |
| #8 | Créer une mission comportant des livrables | Mission sans livrable | Créer une mission et définir ses livrables |
| #6 | Modifier le statut d’une tâche autorisée | Tâche non autorisée | Mettre à jour une tâche interne |
| #16 | Consulter une mission autorisée | Mission non rattachée | Consulter l’avancement client |
| #11 | Valider un livrable en attente | Statut incompatible | Valider un livrable |
| #32 | Demander une révision avec un motif | Motif absent | Demander une révision motivée |
