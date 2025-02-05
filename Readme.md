
---

# **README – Installation de Docker, Git et Python**

## **1. Présentation**

Ce document décrit un **script Bash** (appelons-le `install_basics.sh`) dont le but est d’installer rapidement :

1. **Python3** & **pip3**  
2. **Git**  
3. **Docker**  

sur un système **Debian/Ubuntu**.  
Ce script automatise les tâches habituelles d’installation et simplifie la mise en place d’un environnement standard pour le développement ou la cybersécurité.

---

## **2. Prérequis**

- **Accès root** (ou utilisation de `sudo`).  
- **Connexion internet** pour télécharger les paquets.  
- **Système Debian/Ubuntu** (ou dérivé).  

*Note : Pour d’autres distributions (CentOS, Fedora, etc.), les commandes `apt-get` ne fonctionneront pas. Il faudra adapter.*

---

## **3. Contenu du Script**

Le script `install_basics.sh` :

1. Met à jour la liste des paquets (`apt-get update`)  
2. Met à jour le système (`apt-get upgrade`)  
3. Installe **Python3** et **pip3**  
4. Installe **Git**  
5. Installe **Docker** (le paquet `docker.io`)  
6. Active et démarre le service Docker  

L’installation s’effectue via les commandes :

```bash
apt-get install -y python3 python3-pip git docker.io
```

Puis :

```bash
systemctl enable docker
systemctl start docker
```

---



## **5. Comment l’utiliser ?**

1. **Rendre le script exécutable** :
   ```bash
   chmod +x install_basics.sh
   ```
2. **Exécuter en root** (ou via sudo) :
   ```bash
   sudo ./install_basics.sh
   ```
3. **Vérifier les versions installées** :
   - **Python** :
     ```bash
     python3 --version
     pip3 --version
     ```
   - **Git** :
     ```bash
     git --version
     ```
   - **Docker** :
     ```bash
     docker --version
     systemctl status docker
     ```

---

## **6. Vérifications supplémentaires**

- **Docker** : pour tester rapidement Docker, tu peux exécuter :  
  ```bash
  sudo docker run hello-world
  ```
  Ceci téléchargera l’image `hello-world` et l’exécutera, affichant un message de réussite.  

- **Git** : pour vérifier qu’il fonctionne, fais :  
  ```bash
  git --version
  git clone https://github.com/toto/monrepo.git
  ```
  (remplace `https://github.com/toto/monrepo.git` par un vrai dépôt).

- **Python & pip** :  
  ```bash
  python3 --version
  pip3 --version
  pip3 install requests
  ```
  par exemple.

---

## **7. Désinstallation (optionnel)**

- **Désinstaller Docker** :
  ```bash
  sudo apt-get remove --purge docker.io
  sudo apt-get autoremove
  ```
- **Désinstaller Python3** :  
  Théoriquement possible, mais Python3 est souvent utilisé par le système. À éviter si tu ne veux pas casser le système.  
- **Désinstaller Git** :  
  ```bash
  sudo apt-get remove git
  ```

---

## **8. Conclusion**

Le script `install_basics.sh` fournit un moyen simple et rapide d’obtenir :

- **Python3** + **pip3**  
- **Git**  
- **Docker**  

C’est souvent la base d’un environnement de développement ou d’un lab de cybersécurité.  
**Utilise-le** sur Debian/Ubuntu avec `sudo`, vérifie l’état de Docker, Git et Python après installation, et **personnalise** selon tes besoins.