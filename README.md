# Cloudy (diploma project)

Used links:
(Cloud coverage estimates on photo)


	◦	http://www.bmva.org/bmvc/1992/bmvc-92-045.pdf
	◦	https://www.usgs.gov/faqs/how-percentage-cloud-cover-calculated-a-landsat-scene?qt-news_science_products=0#qt-news_science_products
	◦	https://www.researchgate.net/profile/Bihan_Wen/publication/303847276_Ground-Based_Image_Analysis_A_Tutorial_on_Machine-Learning_Techniques_and_Applications/links/577182c308ae6219474a5a99/Ground-Based-Image-Analysis-A-Tutorial-on-Machine-Learning-Techniques-and-Applications.pdf?origin=publication_detail
	◦	https://www.researchgate.net/publication/307772750_A_method_for_cloud_detection_and_opacity_classification_based_on_ground_based_sky_imagery/fulltext/57d7ab0208ae601b39ac35b2/A-method-for-cloud-detection-and-opacity-classification-based-on-ground-based-sky-imagery.pdf?origin=publication_detail
	◦	https://agupubs.onlinelibrary.wiley.com/doi/pdf/10.1029/2009JD013520
	◦	Retrieving Cloud Characteristics from Ground-Based Daytime Color All-Sky Images | Journal of Atmospheric and Oceanic Technology | American Meteorological Society
	◦	https://www.researchgate.net/publication/336701526_ELIFAN_an_algorithm_for_the_estimation_of_cloud_cover_from_sky_imagers
	◦	https://developer.apple.com/documentation/vision/recognizing_objects_in_live_capture
	◦	https://medium.com/flawless-app-stories/using-sky-segmentation-to-create-stunning-background-animations-in-ios-4b4b2548061
	◦	how to detect sky on photo swift
	◦	https://journals.ametsoc.org/jtech/article/23/3/437/2815/A-Simple-Method-for-the-Assessment-of-the-Cloud
	◦	https://heartbeat.fritz.ai/the-5-computer-vision-techniques-that-will-change-how-you-see-the-world-1ee19334354b\

	◦	rgb to cone coordinate colors
	✓	rgb to cylinder coordinate colors


	◦	https://stackoverflow.com/questions/47283385/how-to-detect-clouds-in-image-using-opencv-python
	◦	https://stackoverflow.com/questions/36332499/image-of-the-sky-analysis-with-opencv
	◦	https://sites.wustl.edu/clouddetection/cloud-detection/fixed-and-adaptive-thresholding/          Transforming colours 
	◦	https://sites.wustl.edu/clouddetection/cloud-detection/comparison-of-thresholding-algorithms/          Transforming colors 



	◦	https://www.google.com/imgres?imgurl=https%3A%2F%2Fsites.wustl.edu%2Fclouddetection%2Ffiles%2F2017%2F12%2Ffigure2-1k9o7sp.png&imgrefurl=https%3A%2F%2Fsites.wustl.edu%2Fclouddetection%2Fcloud-detection%2Ffixed-and-adaptive-thresholding%2F&tbnid=2vpDmWgAvbZN1M&vet=10CBEQxiAoBGoXChMI6KKyj9ri7QIVAAAAAB0AAAAAEAg..i&docid=5w1mZF9RmeZG3M&w=728&h=285&itg=1&q=how%20to%20detect%20cloud%20on%20image&client=safari&ved=0CBEQxiAoBGoXChMI6KKyj9ri7QIVAAAAAB0AAAAAEAg#imgrc=FC9iIYUr0i8gCM&imgdii=zaHw3O58oO9y7M  Transforming image 


Tasks:
	1.	Performance improvement
	2.	Refine the detection of cloud pixels based on the average color of the image
	3.	 Change cloud percentage output view from alert to label, round value of cloud percentage and implement saving all cloud percentage calculation

	◦	https://medium.com/@khalidasad93/simple-low-level-image-processing-in-swift-with-uikit-contrast-35c8bedbd9f2   get negative
	✓	https://www.researchgate.net/publication/321984089_Deep_Convolutional_Neural_Network_for_Cloud_Coverage_Estimation_from_Snapshot_Camera_Images
	✓	https://docs.fritz.ai/develop/vision/image-segmentation/#ios       Get the sky

	✓	https://www.hackingwithswift.com/example-code/media/how-to-read-the-average-color-of-a-uiimage-using-ciareaaverage      Average color


	//1        (0.822368 0.842105 0.888158) 	cloudPecentage: (Zero iteration) 61%  (First iteration) 72%      (Second iteration) 70%          (Third iteration) 73%      (Fourth iteration) 88%      (Fifth iteration) 80%   (80-90%)
        //2        (0.521472 0.662577 0.846626) 	cloudPecentage: (Zero iteration) 68%  (First iteration) 11%      (Second iteration) 2%          (Third iteration) 15%      (Fourth iteration) 100%     (Fifth iteration) 90%   (40-50%)
        //3        (0.247934 0.586777 0.867769) 	cloudPecentage: (Zero iteration) 12%  (First iteration) 0%         (Second iteration) 0%              (Third iteration) 0%       (Fourth iteration) 0%      (Fifth iteration) 0%    (0-5%)
        //4        (0.598639 0.755102 0.85034)             			cloudPecentage: (Zero iteration) 45%  (First iteration) 45%      (Second iteration) 42%          (Third iteration) 46%      (Fourth iteration) 63%      (Fifth iteration) 51%    (40-50%)
        //5        (0.623762 0.69802 0.80198)   	cloudPecentage: (Zero iteration) 55%  (First iteration) 54%      (Second iteration) 48%          (Third iteration) 55%      (Fourth iteration) 85%      (Fifth iteration) 71%    (70-80%)
        // First iteration base (0.6 0.75 0.85)
        // Second iteration base (0.6 0.5 0.85)
        // Third iteration base (0.6 0.85 0.85)
        // Fourth iteration base (0.4 0.85 0.85)
        // Fifth iteration base (0.5 0.85 0.85)

