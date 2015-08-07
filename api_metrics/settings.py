"""
Django settings for API project.

For more information on this file, see
https://docs.djangoproject.com/en/1.6/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/1.6/ref/settings/
"""

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
#import os
#BASE_DIR = os.path.dirname(os.path.dirname(__file__))


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/1.6/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = '7!s6f2wv-w#h=xwiu-hshgixq!5h2276(jg9!kaiv%jiv9+#9l'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

TEMPLATE_DEBUG = True

ALLOWED_HOSTS = []


# Application definition

INSTALLED_APPS = (
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    #'corsheaders',
    'tastypie',
    'api_metrics',
    'metrics',
)
CORS_ORIGIN_ALLOW_ALL = True
CORS_ORIGIN_WHITELIST = ()
CORS_ORIGIN_REGEX_WHITELIST = ()
CORS_URLS_REGEX = '^.*$'
CORS_EXPOSE_HEADERS = ()
CORS_ALLOW_CREDENTIALS = True
CORS_PREFLIGHT_MAX_AGE = 86400

    
MIDDLEWARE_CLASSES = (
    'django.contrib.sessions.middleware.SessionMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
)

ROOT_URLCONF = 'api_metrics.urls'

WSGI_APPLICATION = 'api_metrics.wsgi.application'

ADMINS = (
     ('Jenelin', 'jenelin.garcia@prxcontrolsolutions.com', 
     'Narbelys', 'narbelys.oropeza@prxcontrolsolutions.com'),
)

# Database
# https://docs.djangoproject.com/en/1.6/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2', # Add 'postgresql_psycopg2', 'mysql', 'sqlite3' or 'oracle'.
        'NAME':   'PRX', #'prxsys' ,#'pcaaudit0508', prxcaroni, mapfre, *** aps pcafarma
        'USER': 'jenelin',                      # Not used with sqlite3.
        'PASSWORD': '',                  # Not used with sqlite3.
        #'HOST': '',
        #'PORT': '',
        'HOST': '/var/run/postgresql',                      # Set to empty string for localhost. Not used with sqlite3.
        'PORT': '5433',                      # Set to empty string for default. Not used with sqlite3.                      # Set to empty string for default. Not used with sqlite3.
    }
}

# Internationalization
# https://docs.djangoproject.com/en/1.6/topics/i18n/

LANGUAGE_CODE = 'es'

TIME_ZONE = 'America/Caracas'

USE_I18N = True

USE_L10N = True

USE_TZ = True

# AGREGADO PARA CAMBIAR SIMBOLO DE DECIMAL POR COMA

NUMBER_GROUPING = 3
THOUSAND_SEPARATOR = '.'
DECIMAL_SEPARATOR =','
USE_THOUSAND_SEPARATOR = True
# HASTA ACA


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/1.6/howto/static-files/

STATIC_URL = '/static/'
API_LIMIT_PER_PAGE = 50

## SQLAlchemy

#from sqlalchemy import create_engine
#from sqlalchemy.orm import sessionmaker

# set client encoding to utf8; all strings come back as unicode
#engine = create_engine('sqlite:///:memory:', echo=True)
#engine = create_engine('mysql+mysqldb://root:12qwaszx@localhost/prxsys?charset=utf8') #Aqui va tu conexion de db
#engine = create_engine('postgresql+psycopg2://jenelin:@localhost/PRX?host=/var/local/run/postgresql/9.3.2/') #Aqui va tu conexion de db
#engine = create_engine('postgresql+psycopg2://jenelin:@localhost/prx?host=/var/run/postgresql') #Aqui va tu conexion de db

#SESSION_ALCHEMY = sessionmaker(bind=engine)

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'filters': {
        'require_debug_false': {
            '()': 'django.utils.log.RequireDebugFalse'
        }
    },
    'handlers': {
        'mail_admins': {
            'level': 'DEBUG',
            'filters': ['require_debug_false'],
            'class': 'django.utils.log.AdminEmailHandler'
        }
    },
    'loggers': {
        'django.request': {
            'handlers': ['mail_admins'],
            'level': 'DEBUG',
            'propagate': True,
        },
    }
}


# LOCAL SETTINGS
try:
    from local_settings import *
except ImportError:
    pass
