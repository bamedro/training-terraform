Exercices pratiques
=====================

# Préparation

## Choix et initialisation de l'environnement 
Terraform s'utilise depuis une *console*, avec des commandes Shell.
Ainsi, la méthode la plus simple est d'ouvrir un Cloud Shell sur le cloud utilisé.
Il est également possible d'utiliser une console sur sa machine locale, connectée au cloud.

Cloner ce dépôt sur votre environnement (Cloud Shell ou machine locale)
```
git clone https://github.com/bamedro/training-terraform
```

## Installer Terraform avec TFEnv (recommandé)
TFEnv est un utilitaire qui permet de travailler avec plusieurs versions de Terraform, ce qui est parfois nécessaire lorsque l'on maintien des projets Terraform réalisés à différents moments.
Il va télécharger les binaires de Terraform depuis le site officiel et les stocker dans le répertoire `~/.tfenv/versions/`.
La commande tfenv permet de gérer les versions de Terraform installées sur la machine.

Pour installer TFEnv, il faut exécuter les commandes suivantes :

```bash
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
mkdir ~/bin
ln -s ~/.tfenv/bin/* ~/bin/     # Mettre à jour sa variable PATH si besoin
```

S'assurer de bien être à la raçine du dépôt `training-terraform` et installer lancer l'installation de Terraform via la command `tfenv`.
Cette commande va consulter le fichier `.terraform-version` présent à la raçine du dépôt pour installer la bonne version de Terraform. 
```
tfenv install
```

Les commandes `which terraform` puis `terraform version` permettent respectivement de vérifier l'origin du binaire utilisé et la version effectivement utilisée pour Terraform.


# Exercice 1 : Initialiser et déployer un projet Terraform

Depuis la raçine du dépôt, se rendre dans répertoire correspondant au cloud utilisé (./azure ou ./aws).
Ce répertoire deviendra le *root module* de Terraform.

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
Ce nom peut par exemple se composer du nom de l'application et de l'environnement de cible.
Exemple : tictactoedev (ne pas réutiliser ce nom !)

*Remarque importante :*
Par la suite, le nom de ce workspace sera réutilisé pour créer un espace de stockage dont le nom doit être globalement unique et composé uniquement de caractères alphanumériques minuscules. Pour garantir l'unicité, vous pouvez utiliser votre prénom comme nom d'application

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

# Exercice 3 : Travailler avec un backend remote

Il est possible (et souvent recommandé) d'héberger le fichier Terraform State sur l'infrastructure cloud. Cela offre plusieurs avantages, notamment :
- contrôle d'accès
- partage de l'état possible au sein d'une équipe
- gestion des accès concurrents

Il n'est pas recommandé de stocker le fichier Terraform State dans un dépôt Git, avec les manifests.

## Copie du fichier Terraform State local sur un backend remote
Dans le fichier `terraform.tf`, décommenter le bloc `terraform {...}` et mettre à jour les valeurs avec le `platform_code` utilisé dans l'exercice 1.

Un changement dans la configuration de Terraform implique de *réinitialiser* sa configuration. Pour ce faire, relancer la commande :

```bash
  terraform init
```

... et accepter la copie du fichier local vers le backend remote.

Désormais, le fichier Terraform State est stocké sur le backend remote tel que configuré dans le block `terraform {...}` fu fichier `terraform.tf`.

## Lecture du fichier Terraform State sur le backend remote
Lire les variables de sortie depuis le backend remote.
Pour cela, on peut tester les différentes commande suivante :

```bash
terraform output
terraform output tf_backend_storage_name
terraform output -raw tf_backend_storage_name
```

# Exercice 4 : Ajouter une machine virtuelle au réseau existant

L'objectif de cette étape est de modifier le manifest Terraform pour ajouter une machine virtuelle au sous-réseau existant, qui a été construit dans l'exercice 2. Pour cela, il convient d'ajouter les ressources nécessaires dans le fichier `main.tf` du module racine.

## Cas d'Azure
Pour Azure, il faut ajouter deux ressources :
- `azurerm_virtual_machine`
- `azurerm_network_interface`
Documentation de référence : https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine
az vm image list -p canonical -l francecentral --architecture x64

## Cas d'AWS
Pour AWS, il faut ajouter deux ressources et une datasource :
- `aws_instance`
- `aws_network_interface`
- `aws_ami`
Documentation de référence : https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance



# Exercice 5 : Détruire une infrastructure Terraform

Terraform peut détruire l'infrastructure qu'il a déployé. Cependant, certaines ressources comme le stockage des fichiers Terraform State ne sont pas détruites dans la configuration par défaut, il faut donc parfois passer par une étape de préparation à la destruction.

```bash
terraform destroy -var-file="dev.tfvars"
```
