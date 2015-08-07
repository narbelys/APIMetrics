# -*- coding: utf-8 -*-
ADMINS = (
     ('Narbe', 'narbelys@gmail.com'),
)

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2', # Add 'postgresql_psycopg2', 'mysql', 'sqlite3' or 'oracle'.
        'NAME':   'PRX', #'prxsys' ,#'pcaaudit0508', prxcaroni, mapfre, *** aps pcafarma
        'USER': 'narbe',                      # Not used with sqlite3.
        'PASSWORD': 'root',                  # Not used with sqlite3.
        #'HOST': '',
        #'PORT': '',
        'HOST': 'localhost',                      # Set to empty string for localhost. Not used with sqlite3.
        'PORT': '',   
    }
}

#API_LIMIT_PER_PAGE = 50



