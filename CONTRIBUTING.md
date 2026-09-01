# Contribution

## Cycle de vie du dépôt

Ce dépôt unique est utilisé pour les deux phases du projet :

- Phase 1 : conception et documentation du projet dans `docs/`.
- Phase 2 : code des applications, éléments de base de données, tests et fichiers de déploiement.

## Cycle des branches

Utiliser le cycle de promotion suivant :

```text
feature/* -> dev -> staging -> main
```

Toute modification doit passer par une pull request. Utiliser le squash merge afin de conserver un seul commit par changement.

## Commits

Respecter la convention [Conventional Commits](https://www.conventionalcommits.org/fr/v1.0.0/) :

```text
<type>(optional-scope): concise description
```

Les types courants sont `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `ci` et `build`.

Exemples :

```text
feat(tasks): add custom fields
fix(ci): fetch full Git history
docs: describe the project architecture
```

Rédiger les messages de commit en anglais concis, à l'impératif.

## Secrets et configuration

Ne jamais committer de mots de passe, jetons, clés privées, fichiers `.env`, certificats locaux, sauvegardes de base de données ou poids de modèles d'IA.

Lorsque la configuration d'exécution sera introduite en Phase 2, documenter chaque variable requise dans `.env.example` avec une valeur d'exemple non sensible.
