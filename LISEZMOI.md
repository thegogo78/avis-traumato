# Avis Traumato : version web indépendante

Prototype de télé-expertise en traumatologie, utilisable sans compte Claude.
**Patients fictifs uniquement** : cet hébergement n'est pas certifié HDS.

## Comment c'est construit

- Une page web statique (`index.html`), hébergée gratuitement sur **GitHub Pages**.
- Une base de données et la connexion par lien e-mail chez **Supabase** (offre gratuite).
- `vendor/supabase.js` est la bibliothèque officielle Supabase (v2.117.2), copiée dans le dépôt.
- `supabase/schema.sql` crée les tables et les règles d'accès : tout testeur connecté voit les demandes, chacun ne peut supprimer que les siennes.

## Mise en place (une seule fois)

### 1. Supabase
1. Créer un compte sur supabase.com puis un projet (région Europe, offre gratuite).
2. Menu **SQL Editor** > New query : coller tout `supabase/schema.sql`, puis **Run**.
3. Menu **Project Settings > API** : copier la **Project URL** et la clé **anon public**. Cette clé est publique par conception ; ne jamais partager la clé `service_role`.
4. Menu **Authentication > URL Configuration** : mettre l'adresse GitHub Pages du site dans **Site URL** et dans **Redirect URLs**.

### 2. GitHub
1. Créer un dépôt vide (par exemple `avis-traumato`).
2. Y mettre ces fichiers, avec `config.js` rempli (URL et clé anon).
3. **Settings > Pages** : Source « Deploy from a branch », branche `main`, dossier `/ (root)`.
4. Le site est en ligne à `https://<votre-compte>.github.io/avis-traumato/`.

## Limites à connaître

- **E-mails de connexion** : le service d'envoi intégré de Supabase est limité à quelques e-mails par heure. Au-delà de quelques testeurs, brancher un service d'envoi (Authentication > SMTP Settings, par exemple Brevo, gratuit) ou se connecter moins souvent (la session reste ouverte).
- **Mise en veille** : un projet Supabase gratuit se met en pause après une semaine sans activité ; on le relance d'un clic depuis le tableau de bord.
- **Inscriptions ouvertes** : toute personne qui a l'adresse du site peut se créer un accès. Pour restreindre, désactiver les inscriptions (Authentication > Providers > Email > « Allow new users to sign up ») et inviter les testeurs depuis Authentication > Users.
