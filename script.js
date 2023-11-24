document.addEventListener('DOMContentLoaded', function () {
    var videoButton = document.getElementById('videoButton');
    var descriptionButton = document.getElementById('descriptionButton');
    var videoContent = document.getElementById('videoContent');
    var textContent = document.getElementById('textContent');
    var descriptionContent = document.getElementById('descriptionContent');


    videoButton.classList.add('active');

    videoButton.addEventListener('click', function () {

        videoButton.classList.add('active');
        descriptionButton.classList.remove('active');


        videoContent.classList.add('active');
        textContent.classList.remove('active');
        descriptionContent.classList.remove('active');
    });

    descriptionButton.addEventListener('click', function () {

        videoButton.classList.remove('active');
        descriptionButton.classList.add('active');


        videoContent.classList.remove('active');
        textContent.classList.remove('active');
        descriptionContent.classList.add('active');
    });
});