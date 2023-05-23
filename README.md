Installation de Terraform avec TFEnv (recommandé)
==================================================
Si Terraform n'est pas présent sur la machine, il faut l'installer.
TFEnv est un outil qui permet d'installer et de gérer plusieurs versions de Terraform sur une même machine.
Il va télécharger les binaires de Terraform depuis le site officiel et les stocker dans le répertoire `~/.tfenv/versions/`.
La commande tfenv permet de gérer les versions de Terraform installées sur la machine.

Pour installer TFEnv, il faut exécuter les commandes suivantes :

```bash
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
mkdir ~/bin
ln -s ~/.tfenv/bin/* ~/bin/
tfenv install
tfenv use 1.4.6  # Indiquer la version installée
```

Exercices pratiques
=====================

# Exercice 1 : Initialiser et déployer un projet Terraform

Se rendre dans le répertoire au cloud utilisé (azure ou aws) et se connecter à l'environnement Cloud (facultatif si vous utilisez un Cloud Shell).

Ouvrir et observer le contenu des fichiers présents dans le répertoire :
- dev.tfvars
- main.tf
- output.tf
- variables.tf
- terraform.tf

## Initialiser le projet Terraform

Cette étape va télécharger les plugins nécessaires à l'exécution du projet (en se basant sur la section `required_providers` du fichier `terraform.tf`).

```bash
terraform init
```

Créer ensuite un espace de travail (Workspace) Terraform pour le projet. Cela permet de gérer plusieurs environnements (dev, test, prod, etc.) avec le même manifest Terraform. Chaque Workspace a son propre fichier Terraform State.
Donner un nom unique à ce workspace, par exemple `tictactoedev` pour un environnement de développement.

```bash
terraform workspace new tictactoedev
```

## Préparer et visualiser le plan d'exécution

Cette étape va afficher les actions qui seront réalisées par Terraform pour déployer l'infrastructure.
Nous utilisons le fichier `dev.tfvars` pour fournir les valeurs des variables du manifest Terraform. Pour un autre environnement, nous pourrions utiliser un autre fichier de variables.
Il est également possible d'utiliser des variables d'environnement ou de passer les valeurs directement en ligne de commande.

```bash
terraform plan -var-file="dev.tfvars"
```

## Déployer l'infrastructure

Cette étape va déployer l'infrastructure décrite dans le manifest Terraform. (Répondre "yes" à la question posée par Terraform)

```bash
terraform apply -var-file="dev.tfvars"
```

Constater la création des fichiers tels que décrit par le manifest Terraform, ainsi que la section finale `Outputs`, en résultat de la commande `terraform apply`.
L'état actuel de l'infrastructure, vu par Terraform, se trouve désormais dans le fichier `terraform.tfstate` (localiser le fichier et regarder son contenu).


# Exercice 2 : Mettre à jour une infrastructure Terraform

Nous allons maintenant ajouter des composants d'infrastructure Cloud en mettant à jour le modèle décrit par notre manifest Terraform.
Pour cela, nous allons utiliser les modules Terraform.
Les modules permettent de réutiliser du code Terraform, en encapsulant des ressources et des variables dans un module réutilisable.

Toujours dans le fichier `main.tf`, décommenter les sections `module` :
- tf_backend
- vnet ou vpc (selon le cloud utilisé)

Observer, dans les répertoires `modules` les définitions des modules utilisés.

## Déployer les deux nouveaux modules

Initialiser les nouveaux modules, et déployer la mise à jour de l'infrastructure :

```bash
terraform init
terraform apply -var-file="dev.tfvars"
```

## Générer la clé SSH pour le bastion

On doit générer une clé SSH pour pouvoir se connecter au bastion. On va en profiter pour utiliser un algorithme de chiffrement plus récent que RSA, selon les nouvelles recommandations en termes de sécurité.
Les clés ED25519 sont plus petites que les clés RSA, tout en offrant une meilleure sécurité. Le chiffrement et le déchiffrement sont aussi plus rapides et donc moins coûteux en ressources.

# Exercice 3 : Travailler avec un backend remote

Il est possible (et souvent recommandé) d'héberger le fichier Terraform State sur l'infrastructure cloud. Cela offre plusieurs avantages, notamment :
- contrôle d'accès
- partage de l'état possible au sein d'une équipe
- gestion des accès concurrents

Il n'est pas recommandé de stocker le fichier Terraform State dans un dépôt Git, avec les manifests.

## Copie du fichier Terraform State local sur un backend remote
Décommenter du bloc `terraform {...}` du fichier main.tf et mettre à jour les valeurs avec le `platform_code` que vous avez utilisé dans l'exercice 1.

Relancer la commande :

```bash
  terraform init
```

... et accepter la copie du fichier local vers le backend remote.

Désormais, le fichier Terraform State est stocké sur le backend remote tel que configuré dans le block `terraform {...}` fu fichier `terraform.tf`.

## Lecture du fichier Terraform State sur le backend remote
Lire la valeur de la variable de sortie `public_bastion_ip` depuis le backend remote.
Pour cela, on peut tester les différentes commande suivante :

```bash
terraform output public_bastion_ip
terraform output -json public_bastion_ip
terraform output -raw public_bastion_ip
```

# Exercice 4 : Détruire une infrastructure Terraform

Terraform peut détruire l'infrastructure qu'il a déployé. Cependant, certaines ressources comme le stockage des fichiers Terraform State ne sont pas détruites dans la configuration par défaut, il faut donc parfois passer par une étape de préparation à la destruction.

```bash
terraform destroy -var-file="dev.tfvars"
```
