FROM jenkins:2.46.1

ARG gituser=changeme
ARG gitpass=changeme
ARG jobs_repo=https://github.com/ivans-innovation-lab/my-company-ci-jobs.git



# skip the setup wizard
ENV JAVA_ARGS -Djenkins.install.runSetupWizard=false
RUN echo 2.0 > /usr/share/jenkins/ref/jenkins.install.InstallUtil.lastExecVersion

# install minimum set of plugins
RUN install-plugins.sh \
  blueocean:1.0.1 \
  job-dsl:1.61 \
  git:3.3.0 \
  workflow-aggregator:2.5 \
  maven-plugin:2.15.1 \
  script-security:1.27 \
  pipeline-utility-steps:1.3.0


# create the seed job which spawns all other jobs
RUN mkdir -p /usr/share/jenkins/ref/jobs/seed-job
COPY seedJob.xml /usr/share/jenkins/ref/jobs/seed-job/config.xml
COPY init.groovy /usr/share/jenkins/ref/init.groovy
COPY settings.xml /usr/share/jenkins/settings.xml

USER root
# allow to pass in the jobs repo as a --build-arg
RUN sed -i "s!__JOBS_REPO__!$jobs_repo!" /usr/share/jenkins/ref/jobs/seed-job/config.xml
RUN sed -i "s!__GIT_USER__!$gituser!" /usr/share/jenkins/settings.xml
RUN sed -i "s!__GIT_PASSWORD__!$gitpass!" /usr/share/jenkins/settings.xml


RUN printf "%s" "${gituser}" > /usr/share/jenkins/gituser
RUN printf "%s" "${gitpass}" > /usr/share/jenkins/gitpass

USER jenkins
