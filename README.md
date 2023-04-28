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

Se rendre dans le répertoire du `core` du cloud choisit (azure ou aws) et se connecter à l'environnement Cloud (facultatif si vous utilisez un Cloud Shell).

## Définir les paramètres du projet

Ouvrir le fichier  `test.auto.tfvars`.
Ce fichier contient une liste de variables qui seront utilisées pour paramétrer le déploiement que nous allons réaliser.

Mettre à jour uniquement la valeur de la variable `platform_code` avec un identifiant unique tel que votre prénom (sans accent).

## Initialiser le projet Terraform

Cette étape va télécharger les plugins nécessaires à l'exécution du projet (en se basant sur la section `required_providers` du fichier `main.tf`).

```bash
terraform init
```

## Vérifier le plan d'exécution

Cette étape va afficher les actions qui seront réalisées par Terraform pour déployer l'infrastructure.

```bash
terraform plan
```

## Déployer l'infrastructure

Cette étape va déployer l'infrastructure sur le cloud.

```bash
terraform apply
```


# Exercice 2 : Mettre à jour une infrastructure Terraform

L'état actuel de l'infrastructure, vu par Terraform, se trouve désormais dans le fichier `terraform.tfstate`.

Nous allons maintenant ajouter un bastion à l'infrastructure en modifiant le modèle décrit par notre manifest Terraform.

## Générer la clé SSH pour le bastion

On doit générer une clé SSH pour pouvoir se connecter au bastion. On va en profiter pour utiliser un algorithme de chiffrement plus récent que RSA, selon les nouvelles recommandations en termes de sécurité.
Par ailleurs, les clés ED25519 sont plus petites que les clés RSA, tout en offrant une meilleure sécurité. Le chiffrement et le déchiffrement sont aussi plus rapides et donc moins coûteux en ressources.

```bash
ssh-keygen -t ed25519
```

## Ajout du bastion dans le fichier main.tf
Indiquer `bastion = 1` dans le bloc `locals` du fichier `main.tf` et observer comment cette variable est utilisée dans la section *Création d'un bastion*, à la fin du fichier `main.tf`.

## Utilisation des valeurs de sortie du fichier outputs.tf
Décommenter la section `output` du fichier `outputs.tf`.

## Appliquer les modifications sur l'infrastructure

```bash
terraform apply
```

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

Désormais, le fichier Terraform State est stocké sur le backend remote tel que configuré dans le block `terraform {...}` fu fichier `main.tf`.

## Lecture du fichier Terraform State sur le backend remote
Lire la valeur de la variable de sortie `bastion_public_ip` depuis le backend remote, grâce à la commande suivante :

```bash
terraform output bastion_public_ip
```

# Exercice 4 : Détruire une infrastructure Terraform

Terraform peut détruire l'infrastructure qu'il a déployé. Cependant, certaines ressources comme le stockage des fichiers Terraform State ne sont pas détruites dans la configuration par défaut, il faut donc passer par une étape de préparation à la destruction.

Pour cela, décommenter la ligne indiquée dans le bloc en charge de la gestion du stockage (dans le fichier `main.tf`), puis appliquer ces modifications à l'infrastructure :

```bash
terraform apply
```

Enfin, pour détruire l'infrastructure, il suffit d'exécuter la commande suivante :

```bash
terraform destroy
```