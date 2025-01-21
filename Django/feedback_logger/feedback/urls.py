from django.urls import path
from . import views
from .views import serve_media


urlpatterns = [
    path('', views.landing_page, name='landing_page'),
    path('form/', views.feedback_form, name='feedback_form'),
    path('list/', views.feedback_list, name='feedback_list'),
    path('media/<path:path>/', serve_media, name='serve_media'),
    path('delete/<int:feedback_id>/', views.delete_feedback, name='delete_feedback'),
    path('update/<int:feedback_id>/', views.update_feedback, name='update_feedback'), 

]
