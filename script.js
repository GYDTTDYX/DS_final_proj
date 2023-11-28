function toggleContent(contentType) {
    var videoButton = document.getElementById('videoButton');
    var descriptionButton = document.getElementById('descriptionButton');
    var videoContent = document.getElementById('videoContent');
    var descriptionContent = document.getElementById('descriptionContent');

    if (contentType === 'video') {
        videoButton.classList.add('active');
        descriptionButton.classList.remove('active');
        videoContent.classList.add('active');
        descriptionContent.classList.remove('active');
    } else if (contentType === 'description') {
        videoButton.classList.remove('active');
        descriptionButton.classList.add('active');
        videoContent.classList.remove('active');
        descriptionContent.classList.add('active');
    }
}