from django.shortcuts import render, redirect, get_object_or_404
from django.http import HttpResponse, FileResponse, HttpResponseNotFound
from .models import Feedback
from django.conf import settings
from django.core.cache import cache

import os
import logging

logger = logging.getLogger('application')


def feedback_form(request):
    if request.method == 'POST':
        name = request.POST['name']
        email = request.POST['email']
        message = request.POST['message']
        attachment = request.FILES.get('attachment')
        feedback = Feedback(name=name, email=email, message=message, attachment=attachment)
        feedback.save()
        cache.delete('recent_feedbacks')
        logger.info(f"Added Feedback | File: {attachment.name if attachment else 'No file'} | Email: {email}")
        return render(request, 'feedback/feedback_success.html', {'name': name})
    return render(request, 'feedback/feedback_form.html')


from django.core.cache import cache
from .models import Feedback

def feedback_list(request):
    # Try to get feedback data from the cache
    cached_feedbacks = cache.get('recent_feedbacks')
    if cached_feedbacks is None:
        logger.info("Cache miss: Fetching feedbacks from the database.")
        feedbacks = Feedback.objects.all().order_by('-created_at')

        # Cache the feedback data for 5 minutes (300 seconds)
        cache.set('recent_feedbacks', feedbacks, timeout=3000)
        logger.info("Feedbacks cached successfully.")
    else:
        logger.info("Cache hit: Using cached feedbacks.")
        feedbacks = cached_feedbacks

    return render(request, 'feedback/feedback_list.html', {'feedbacks': feedbacks})


def landing_page(request):
    return render(request, 'landing_page.html')

def serve_media(request, path):
    file_path = os.path.join(settings.MEDIA_ROOT, path)
    if os.path.exists(file_path):
        return FileResponse(open(file_path, 'rb'), as_attachment=True)
    else:
        return HttpResponseNotFound("File not found.")

def delete_feedback(request, feedback_id):
    feedback = get_object_or_404(Feedback, id=feedback_id)
    if request.method == 'POST':
        feedback.delete()  
        cache.delete('recent_feedbacks')
        logger.info(f"Deleted Feedback | Email: {feedback.email} | Message: {feedback.message} | File: {feedback.attachment.name if feedback.attachment else 'No file'}")
        return redirect('feedback_list')  
    return render(request, 'feedback/delete_feedback.html', {'feedback': feedback})


from django.shortcuts import get_object_or_404, redirect, render

def update_feedback(request, feedback_id):
    feedback = get_object_or_404(Feedback, id=feedback_id)
    if request.method == 'POST':
        old_message = feedback.message  # Capture the old message for logging
        feedback.message = request.POST.get('message')
        feedback.save()
        cache.delete('recent_feedbacks')

        # Optional: Log the update (if logging is enabled)
        logger.info(f"Updated Feedback ID {feedback.id} | Email: {feedback.email} | Old Message: {old_message} | New Message: {feedback.message}")

        return redirect('feedback_list')
    return render(request, 'feedback/update_feedback.html', {'feedback': feedback})
