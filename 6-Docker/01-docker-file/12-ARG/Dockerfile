######use case -1 ##################
FROM almalinux:9
ARG course="docker" \
    trainer="venkat" \
    duration="100hrs"
RUN echo "Course is: ${course}, Duration is: ${duration}, from the Trainer: ${trainer}"

####### Use case -2 ########mostley used this use case
ARG version
FROM almalinux:${version:-9}
ARG course="docker" \
    trainer="venkat" \
    duration="100hrs"
RUN echo "Course is: ${course}, Duration is: ${duration}, from the Trainer: ${trainer}"