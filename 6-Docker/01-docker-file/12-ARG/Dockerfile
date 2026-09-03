# ######use case -1 ##################
# FROM almalinux:9
# ARG course="docker" \
#     trainer="venkat" \
#     duration="100hrs"
# RUN echo "Course is: ${course}, Duration is: ${duration}, from the Trainer: ${trainer}"

####### Use case -2 ########mostley used this case
# ARG version
# FROM almalinux:${version:-9}
# ARG course="docker" \
#     trainer="venkat" \
#     duration="100hrs"
# RUN echo "Course is: ${course}, Duration is: ${duration}, from the Trainer: ${trainer}"

## we pass in command line as --build-arg version=10
############ Usecase -3 ######### rarely used for environment variable 
ARG version
FROM almalinux:${version:-9}
ARG course="docker" \
    trainer="venkat" \
    duration="100hrs"
ENV course=${course} \
    trainer=${trainer} \
    duration=${duration}
RUN echo "Course is: ${course}, Duration is: ${duration}, from the Trainer: ${trainer}"