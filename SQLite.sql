CREATE TABLE IF NOT EXISTS admins (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL,
    password TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS posts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    image_url TEXT,
    admin_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES admins (id)
);

INSERT OR IGNORE INTO admins (username, password) VALUES ('admin', 'admin123');
INSERT OR IGNORE INTO posts (title, content, admin_id) VALUES 
('Premier article', 'Contenu du premier article', 1),
('Deuxième article', 'Contenu du deuxième article', 1);

-- SQLite.sql - Base de données complète du centre
-- =====================================================

-- Garder les tables existantes (admins et posts déjà créées)

-- 1. TABLE: history_achievements (Section I - Historicité)
CREATE TABLE IF NOT EXISTS history_achievements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    type TEXT CHECK(type IN ('history', 'achievement')) NOT NULL,
    image_url TEXT,
    date_event DATE,
    is_featured INTEGER DEFAULT 0,
    display_order INTEGER DEFAULT 0,
    status TEXT CHECK(status IN ('draft', 'published')) DEFAULT 'published',
    admin_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES admins (id)
);

-- 2. TABLE: professionals (Section II - Professionnels)
CREATE TABLE IF NOT EXISTS professionals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    first_name TEXT NOT NULL,
    last_name TEXT NOT NULL,
    academic_level TEXT NOT NULL,
    study_domain TEXT NOT NULL,
    profile_image_url TEXT,
    video_url TEXT,
    email TEXT,
    phone TEXT,
    biography TEXT,
    skills TEXT,
    status TEXT CHECK(status IN ('active', 'inactive')) DEFAULT 'active',
    is_featured INTEGER DEFAULT 0,
    display_order INTEGER DEFAULT 0,
    admin_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES admins (id)
);

-- 3. TABLE: intervention_axes (Section IV - Axes fixes)
CREATE TABLE IF NOT EXISTS intervention_axes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    icon_url TEXT,
    color_code TEXT,
    is_active INTEGER DEFAULT 1,
    display_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. TABLE: projects (Section IV - Projets par axe)
CREATE TABLE IF NOT EXISTS projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    short_description TEXT,
    intervention_axis_id INTEGER NOT NULL,
    start_date DATE,
    end_date DATE,
    status TEXT CHECK(status IN ('planning', 'active', 'completed', 'paused')) DEFAULT 'planning',
    budget DECIMAL(10,2),
    objectives TEXT,
    results TEXT,
    image_url TEXT,
    documents_url TEXT,
    contact_person_id INTEGER,
    is_featured INTEGER DEFAULT 0,
    admin_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (intervention_axis_id) REFERENCES intervention_axes (id),
    FOREIGN KEY (contact_person_id) REFERENCES professionals (id),
    FOREIGN KEY (admin_id) REFERENCES admins (id)
);

-- 5. TABLE: publication_categories (Section III - Catégories)
CREATE TABLE IF NOT EXISTS publication_categories (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    slug TEXT NOT NULL UNIQUE,
    description TEXT,
    display_order INTEGER DEFAULT 0,
    is_active INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. TABLE: scientific_publications (Section III - Publications)
CREATE TABLE IF NOT EXISTS scientific_publications (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    abstract TEXT,
    category_id INTEGER NOT NULL,
    author_main TEXT NOT NULL,
    co_authors TEXT,
    publication_date DATE,
    university TEXT,
    study_domain TEXT,
    keywords TEXT,
    language TEXT CHECK(language IN ('fr', 'en', 'other')) DEFAULT 'fr',
    pages_count INTEGER,
    pdf_url TEXT,
    file_size INTEGER,
    download_count INTEGER DEFAULT 0,
    intervention_axis_id INTEGER,
    professional_id INTEGER,
    status TEXT CHECK(status IN ('draft', 'published')) DEFAULT 'published',
    is_featured INTEGER DEFAULT 0,
    admin_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES publication_categories (id),
    FOREIGN KEY (intervention_axis_id) REFERENCES intervention_axes (id),
    FOREIGN KEY (professional_id) REFERENCES professionals (id),
    FOREIGN KEY (admin_id) REFERENCES admins (id)
);

-- 7. TABLE: project_participants (Relation Many-to-Many)
CREATE TABLE IF NOT EXISTS project_participants (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    professional_id INTEGER NOT NULL,
    role TEXT,
    start_date DATE,
    end_date DATE,
    is_active INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (project_id) REFERENCES projects (id),
    FOREIGN KEY (professional_id) REFERENCES professionals (id),
    UNIQUE(project_id, professional_id)
);

-- 8. TABLE: media_gallery (Galerie globale)
CREATE TABLE IF NOT EXISTS media_gallery (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    file_url TEXT NOT NULL,
    file_type TEXT CHECK(file_type IN ('image', 'video')) NOT NULL,
    file_size INTEGER,
    mime_type TEXT,
    related_table TEXT,
    related_id INTEGER,
    alt_text TEXT,
    is_featured INTEGER DEFAULT 0,
    display_order INTEGER DEFAULT 0,
    admin_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES admins (id)
);

-- =====================================================
-- DONNÉES INITIALES
-- =====================================================

-- Insérer les axes d'intervention fixes
INSERT OR IGNORE INTO intervention_axes (name, slug, description, display_order) VALUES 
('Administration et finances', 'administration-finances', 'Gestion administrative et financière du centre', 1),
('Éducation', 'education', 'Projets éducatifs et formation', 2),
('Santé', 'sante', 'Initiatives de santé publique et bien-être', 3),
('Environnement et Agriculture', 'environnement-agriculture', 'Projets environnementaux et agricoles durables', 4);

-- Insérer les catégories de publications
INSERT OR IGNORE INTO publication_categories (name, slug, description, display_order) VALUES 
('Articles scientifiques', 'articles-scientifiques', 'Articles publiés dans des revues scientifiques', 1),
('Thèses de doctorat', 'theses-doctorat', 'Thèses de doctorat soutenues', 2),
('Mémoires de Maîtrise', 'memoires-maitrise', 'Mémoires de niveau Master/Maîtrise', 3),
('Mémoires de Licence', 'memoires-licence', 'Mémoires de niveau Licence/Bachelor', 4),
('Autres publications', 'autres-publications', 'Autres types de publications académiques', 5);

-- Garder l'admin existant
INSERT OR IGNORE INTO admins (username, password) VALUES ('admin', 'admin123');

-- Quelques données d'exemple pour tester
INSERT OR IGNORE INTO history_achievements (title, content, type, date_event) VALUES 
('Création du centre', 'Fondation officielle du centre avec pour mission d accompagner les jeunes professionnels', 'history', '2020-01-15'),
('Premier programme de formation', 'Lancement du premier programme de formation en entrepreneuriat', 'achievement', '2020-06-01');

INSERT OR IGNORE INTO professionals (first_name, last_name, academic_level, study_domain, biography) VALUES 
('Jean', 'Dupont', 'Master', 'Informatique', 'Développeur passionné par les nouvelles technologies'),
('Marie', 'Martin', 'Licence', 'Économie', 'Spécialisée en microfinance et développement local');

-- =====================================================
-- INDEX POUR OPTIMISATION
-- =====================================================

-- Index pour les recherches
CREATE INDEX IF NOT EXISTS idx_professionals_domain ON professionals(study_domain);
CREATE INDEX IF NOT EXISTS idx_publications_keywords ON scientific_publications(keywords);
CREATE INDEX IF NOT EXISTS idx_publications_category ON scientific_publications(category_id);
CREATE INDEX IF NOT EXISTS idx_projects_axis ON projects(intervention_axis_id);
CREATE INDEX IF NOT EXISTS idx_publications_title ON scientific_publications(title);
CREATE INDEX IF NOT EXISTS idx_professionals_name ON professionals(last_name, first_name);

-- Index pour les filtres
CREATE INDEX IF NOT EXISTS idx_professionals_status ON professionals(status);
CREATE INDEX IF NOT EXISTS idx_publications_status ON scientific_publications(status);
CREATE INDEX IF NOT EXISTS idx_projects_status ON projects(status);
CREATE INDEX IF NOT EXISTS idx_featured ON professionals(is_featured);

-- =====================================================
-- VÉRIFICATION
-- =====================================================

-- Vérifier les données insérées
SELECT 'Axes d intervention créés:' as info;
SELECT * FROM intervention_axes;

SELECT 'Catégories de publications créées:' as info;
SELECT * FROM publication_categories;

SELECT 'Professionnels d exemple créés:' as info;
SELECT * FROM professionals;

SELECT 'Réalisations historiques créées:' as info;
SELECT * FROM history_achievements;

-- =====================================================
-- SECTION V - PARTENAIRES DU CENTRE
-- Table complète pour gérer tous types de partenaires
-- =====================================================

-- Table principale des partenaires
CREATE TABLE IF NOT EXISTS partners (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    
    -- Informations de base
    partner_type TEXT CHECK(partner_type IN ('individual', 'organization', 'company', 'institution', 'ngo', 'government', 'association', 'university')) NOT NULL,
    
    -- Nom (pour personne physique)
    first_name TEXT,
    last_name TEXT,
    
    -- Nom (pour organisation)
    organization_name TEXT,
    
    -- Informations visuelles
    profile_image_url TEXT,
    logo_url TEXT,
    
    -- Contact
    email TEXT,
    phone TEXT,
    secondary_phone TEXT,
    website_url TEXT,
    
    -- Adresse complète
    address_line1 TEXT,
    address_line2 TEXT,
    city TEXT,
    postal_code TEXT,
    country TEXT DEFAULT 'France',
    
    -- Réseaux sociaux
    linkedin_url TEXT,
    facebook_url TEXT,
    twitter_url TEXT,
    instagram_url TEXT,
    
    -- Informations professionnelles
    position_title TEXT, -- Poste/fonction dans l'organisation
    department TEXT, -- Département/service
    activity_sector TEXT, -- Secteur d'activité
    specializations TEXT, -- Spécialisations/domaines d'expertise
    
    -- Description
    short_description TEXT, -- Description courte (1-2 lignes)
    detailed_description TEXT, -- Description détaillée/biographie
    
    -- Informations de partenariat
    partnership_type TEXT CHECK(partnership_type IN ('strategic', 'operational', 'financial', 'technical', 'academic', 'institutional', 'community', 'media')) NOT NULL,
    collaboration_level TEXT CHECK(collaboration_level IN ('occasional', 'regular', 'strategic', 'exclusive')) DEFAULT 'regular',
    partnership_start_date DATE,
    partnership_end_date DATE,
    
    -- Domaines de collaboration
    collaboration_domains TEXT, -- JSON ou texte avec domaines séparés par virgules
    youth_focus_areas TEXT, -- Domaines spécifiques pour la jeunesse
    
    -- Services/Ressources apportés
    services_provided TEXT, -- Services que le partenaire apporte
    resources_available TEXT, -- Ressources disponibles
    expertise_areas TEXT, -- Domaines d'expertise
    
    -- Projets et activités
    past_projects TEXT, -- Projets passés en commun
    ongoing_projects TEXT, -- Projets en cours
    planned_activities TEXT, -- Activités prévues
    
    -- Documents et références
    partnership_agreement_url TEXT, -- Lien vers accord de partenariat
    documents_url TEXT, -- Autres documents
    testimonial TEXT, -- Témoignage du partenaire
    
    -- Métriques et impact
    years_of_partnership INTEGER, -- Nombre d'années de partenariat
    youth_impacted INTEGER, -- Nombre de jeunes touchés
    projects_completed INTEGER, -- Nombre de projets réalisés ensemble
    
    -- Informations organisationnelles (pour organisations)
    organization_size TEXT CHECK(organization_size IN ('startup', 'small', 'medium', 'large', 'enterprise')),
    founding_year INTEGER,
    legal_status TEXT, -- Statut juridique
    registration_number TEXT, -- Numéro d'enregistrement
    
    -- Géolocalisation et portée
    geographic_scope TEXT CHECK(geographic_scope IN ('local', 'regional', 'national', 'international')),
    target_regions TEXT, -- Régions d'intervention
    
    -- Contact principal (si différent)
    contact_person_name TEXT,
    contact_person_position TEXT,
    contact_person_email TEXT,
    contact_person_phone TEXT,
    
    -- Visibilité et mise en avant
    is_featured INTEGER DEFAULT 0, -- Partenaire mis en avant
    is_active INTEGER DEFAULT 1, -- Partenariat actif
    display_order INTEGER DEFAULT 0, -- Ordre d'affichage
    visibility_level TEXT CHECK(visibility_level IN ('public', 'limited', 'private')) DEFAULT 'public',
    
    -- Tags et catégorisation
    tags TEXT, -- Tags pour classification
    keywords TEXT, -- Mots-clés pour recherche
    
    -- Métadonnées
    admin_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (admin_id) REFERENCES admins (id)
);

-- Table pour les activités communes spécifiques
CREATE TABLE IF NOT EXISTS partner_activities (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    partner_id INTEGER NOT NULL,
    
    -- Informations de l'activité
    activity_title TEXT NOT NULL,
    activity_description TEXT,
    activity_type TEXT CHECK(activity_type IN ('formation', 'workshop', 'conference', 'project', 'mentoring', 'internship', 'exchange', 'competition', 'event', 'research')) NOT NULL,
    
    -- Public cible
    target_audience TEXT, -- Jeunes professionnels, étudiants, etc.
    age_range TEXT, -- Tranche d'âge visée
    participant_capacity INTEGER, -- Nombre max de participants
    
    -- Dates et fréquence
    start_date DATE,
    end_date DATE,
    frequency TEXT CHECK(frequency IN ('one-time', 'weekly', 'monthly', 'quarterly', 'annual')),
    duration_hours INTEGER, -- Durée en heures
    
    -- Localisation
    location TEXT,
    is_virtual INTEGER DEFAULT 0,
    
    -- Ressources
    resources_needed TEXT,
    budget_estimated DECIMAL(10,2),
    
    -- Statut et suivi
    status TEXT CHECK(status IN ('planned', 'ongoing', 'completed', 'cancelled')) DEFAULT 'planned',
    participants_count INTEGER DEFAULT 0,
    
    -- Impact
    success_metrics TEXT,
    feedback_summary TEXT,
    lessons_learned TEXT,
    
    -- Médias
    images_url TEXT,
    videos_url TEXT,
    documents_url TEXT,
    
    -- Métadonnées
    is_featured INTEGER DEFAULT 0,
    admin_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (partner_id) REFERENCES partners (id) ON DELETE CASCADE,
    FOREIGN KEY (admin_id) REFERENCES admins (id)
);

-- Table pour les contacts multiples (si un partenaire a plusieurs contacts)
CREATE TABLE IF NOT EXISTS partner_contacts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    partner_id INTEGER NOT NULL,
    
    contact_name TEXT NOT NULL,
    contact_position TEXT,
    contact_email TEXT,
    contact_phone TEXT,
    contact_type TEXT CHECK(contact_type IN ('primary', 'secondary', 'technical', 'administrative', 'financial')),
    
    is_active INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (partner_id) REFERENCES partners (id) ON DELETE CASCADE
);

-- =====================================================
-- INDEX POUR OPTIMISATION
-- =====================================================

-- Index pour les recherches fréquentes
CREATE INDEX IF NOT EXISTS idx_partners_type ON partners(partner_type);
CREATE INDEX IF NOT EXISTS idx_partners_partnership_type ON partners(partnership_type);
CREATE INDEX IF NOT EXISTS idx_partners_active ON partners(is_active);
CREATE INDEX IF NOT EXISTS idx_partners_featured ON partners(is_featured);
CREATE INDEX IF NOT EXISTS idx_partners_sector ON partners(activity_sector);
CREATE INDEX IF NOT EXISTS idx_partners_collaboration_level ON partners(collaboration_level);
CREATE INDEX IF NOT EXISTS idx_partners_geographic_scope ON partners(geographic_scope);

-- Index pour les noms (recherche par nom)
CREATE INDEX IF NOT EXISTS idx_partners_names ON partners(last_name, first_name);
CREATE INDEX IF NOT EXISTS idx_partners_organization ON partners(organization_name);

-- Index pour les activités
CREATE INDEX IF NOT EXISTS idx_activities_partner ON partner_activities(partner_id);
CREATE INDEX IF NOT EXISTS idx_activities_type ON partner_activities(activity_type);
CREATE INDEX IF NOT EXISTS idx_activities_status ON partner_activities(status);
CREATE INDEX IF NOT EXISTS idx_activities_dates ON partner_activities(start_date, end_date);

-- =====================================================
-- DONNÉES D'EXEMPLE
-- =====================================================

-- Insérer quelques partenaires d'exemple
INSERT OR IGNORE INTO partners (
    partner_type, first_name, last_name, organization_name, 
    email, phone, website_url, 
    partnership_type, collaboration_level, 
    activity_sector, short_description, detailed_description,
    collaboration_domains, youth_focus_areas,
    partnership_start_date, is_active, is_featured
) VALUES 
(
    'individual', 'Dr. Sophie', 'Dubois', NULL,
    'sophie.dubois@email.com', '+33123456789', 'https://sophie-dubois.fr',
    'academic', 'strategic',
    'Psychologie du développement', 'Psychologue spécialisée dans l accompagnement des jeunes',
    'Docteure en psychologie avec 15 ans d expérience dans l accompagnement des jeunes professionnels. Formatrice certifiée en développement personnel et orientation professionnelle.',
    'Formation professionnelle, Développement personnel, Orientation', 'Insertion professionnelle, Confiance en soi, Gestion du stress',
    '2022-01-15', 1, 1
),
(
    'organization', NULL, NULL, 'Association Jeunes Entrepreneurs',
    'contact@jeunes-entrepreneurs.org', '+33987654321', 'https://jeunes-entrepreneurs.org',
    'strategic', 'regular',
    'Entrepreneuriat', 'Association dédiée à l accompagnement des jeunes entrepreneurs',
    'Association créée en 2018 pour accompagner les jeunes dans la création d entreprise. Plus de 500 jeunes accompagnés avec un taux de réussite de 78%.',
    'Entrepreneuriat, Formation, Mentorat, Financement', 'Création d entreprise, Business plan, Recherche de financement',
    '2021-09-01', 1, 1
),
(
    'company', NULL, NULL, 'TechnoVision SARL',
    'partenariat@technovision.fr', '+33456789123', 'https://technovision.fr',
    'technical', 'occasional',
    'Technologies numériques', 'Entreprise spécialisée en solutions digitales',
    'Entreprise innovante dans le domaine des technologies émergentes. Propose des stages et formations en IA, blockchain et cybersécurité.',
    'Formation technique, Stages, Innovation', 'Compétences numériques, Intelligence artificielle, Cybersécurité',
    '2023-03-20', 1, 0
);

-- Insérer quelques activités d'exemple
INSERT OR IGNORE INTO partner_activities (
    partner_id, activity_title, activity_description, activity_type,
    target_audience, start_date, end_date, status, location
) VALUES 
(
    1, 'Atelier Confiance en Soi', 'Atelier mensuel pour développer la confiance en soi des jeunes professionnels', 'workshop',
    'Jeunes professionnels 20-30 ans', '2024-01-15', '2024-12-15', 'ongoing', 'Centre de formation'
),
(
    2, 'Concours Jeunes Entrepreneurs', 'Concours annuel pour récompenser les meilleures idées entrepreneuriales', 'competition',
    'Étudiants et jeunes diplômés', '2024-03-01', '2024-06-30', 'planned', 'Auditorium universitaire'
),
(
    3, 'Stage en IA', 'Programme de stage de 3 mois en intelligence artificielle', 'internship',
    'Étudiants en informatique', '2024-06-01', '2024-08-31', 'planned', 'Bureaux TechnoVision'
);

-- =====================================================
-- VÉRIFICATION DES DONNÉES
-- =====================================================

SELECT 'Partenaires créés:' as info;
SELECT partner_type, 
       COALESCE(organization_name, first_name || ' ' || last_name) as name,
       partnership_type, 
       collaboration_level,
       is_active
FROM partners;

SELECT 'Activités partenaires créées:' as info;
SELECT pa.activity_title, 
       pa.activity_type,
       COALESCE(p.organization_name, p.first_name || ' ' || p.last_name) as partner_name,
       pa.status
FROM partner_activities pa
JOIN partners p ON pa.partner_id = p.id;

INSERT INTO intervention_axes (name, slug, description, display_order, is_active) 
VALUES ('Droit', 'droit', 'Accompagnement juridique et conseil en droit', 5, 1);

--UPDATE le mot de passe de l'admin
UPDATE admins SET password = 'nouveaumotdepasse' WHERE username = 'admin';
-- Créer un nouvel admin
INSERT INTO admins (username, password) VALUES ('admin2', 'sonmotdepasse');