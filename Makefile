VOTER_IMG=voter
BALLOT_IMG=ballot
ECSVR_IMG=ecserver
TEST_IMG=service-test-suite
EC_IMG=election-commission
ifndef IMAGE_TAG
  IMAGE_TAG=latest
endif

# HOSTNAME := $(shell hostname)
.PHONY: all
all: dockerise deploy

.PHONY: test
test: test-ballot test-voter test-ecserver

.PHONY: test-ballot
test-ballot:
	echo "Test Ballot"
	docker run --network="host" --rm -it -v ${PWD}/ballot/test:/scripts \
   zbio/artillery-custom \
   run -e unit /scripts/test.yaml

.PHONY: test-voter
test-voter:
	echo "Test Voter"
	mkdir -p /var/tmp/test
	mkdir -p /var/tmp/test/cypress
	mkdir -p /var/tmp/test/cypress/integration
	echo '{"reporter": "junit","reporterOptions": {"mochaFile": "results/my-test-output-[hash].xml"}}' > /var/tmp/test/cypress.json
	cp ${PWD}/service-test-suite/voter/voter.spec.js /var/tmp/test/cypress/integration
	docker run --network="host"  -v /var/tmp/test:/e2e -w /e2e cypress/included:6.2.1 --browser firefox

.PHONY: test-ecserver
test-ecserver:
	echo "Test ECserver"
	docker run --network="host" --rm -it -v ${PWD}/ecserver/test:/scripts \
   zbio/artillery-custom \
   run -e unit /scripts/test.yaml

.PHONY: dockerise
dockerise: build-voter build-ballot build-ecserver build-ec build-test

.PHONY: build-ballot
build-ballot:
ifdef DOCKER_HOST
	docker build -H ${DOCKER_HOST} -t ${BALLOT_IMG}:${IMAGE_TAG} -f ballot/Dockerfile ballot
else
	docker build -t ${BALLOT_IMG}:${IMAGE_TAG} -f ballot/Dockerfile ballot
endif

.PHONY: build-voter
build-voter:
ifdef DOCKER_HOST
	docker build -H ${DOCKER_HOST} -t ${VOTER_IMG}:${IMAGE_TAG} -f voter/Dockerfile voter
else
	docker build -t ${VOTER_IMG}:${IMAGE_TAG} -f voter/Dockerfile voter	
endif

.PHONY: build-ecserver
build-ecserver:
ifdef DOCKER_HOST
	docker build -H ${DOCKER_HOST} -t ${ECSVR_IMG}:${IMAGE_TAG} -f ecserver/Dockerfile ecserver
else
	docker build -t ${ECSVR_IMG}:${IMAGE_TAG} -f ecserver/Dockerfile ecserver
endif

.PHONY: build-test
build-test:
ifdef DOCKER_HOST
	docker build -H ${DOCKER_HOST} -t ${TEST_IMG}:${IMAGE_TAG} -f service-test-suite/Dockerfile service-test-suite
else
	docker build -t ${TEST_IMG}:${IMAGE_TAG} -f service-test-suite/Dockerfile service-test-suite
endif

.PHONY: build-ec
build-ec:
ifdef DOCKER_HOST
	docker build -H ${DOCKER_HOST} -t ${EC_IMG}:${IMAGE_TAG} -f election-commission/Dockerfile election-commission
else
	docker build -t ${EC_IMG}:${IMAGE_TAG} -f election-commission/Dockerfile election-commission
endif
		
.PHONY: push
push:
	docker tag ${BALLOT_IMG}:${IMAGE_TAG} zbio/${BALLOT_IMG}:${IMAGE_TAG}
	docker push zbio/${BALLOT_IMG}:${IMAGE_TAG}
	docker tag ${VOTER_IMG}:${IMAGE_TAG} zbio/${VOTER_IMG}:${IMAGE_TAG}
	docker push zbio/${VOTER_IMG}:${IMAGE_TAG}
	docker tag ${ECSVR_IMG}:${IMAGE_TAG} zbio/${ECSVR_IMG}:${IMAGE_TAG}
	docker push zbio/${ECSVR_IMG}:${IMAGE_TAG}
	docker tag ${EC_IMG}:${IMAGE_TAG} zbio/${EC_IMG}:${IMAGE_TAG}
	docker push zbio/${EC_IMG}:${IMAGE_TAG}
	docker tag ${TEST_IMG}:${IMAGE_TAG} zbio/${TEST_IMG}:${IMAGE_TAG}
	docker push zbio/${TEST_IMG}:${IMAGE_TAG}

.PHONY: deploy
deploy:
	kubectl apply -f ecserver/ecserver.yaml
	kubectl apply -f ballot/ballot.yaml
	kubectl apply -f voter/voter.yaml
	kubectl apply -f service-test-suite/test-suite.yaml
	kubectl apply -f election-commission/ec.yaml
	kubectl apply -f ingress.yaml

.PHONY: clean
clean:
	-kubectl delete -f service-test-suite/test-suite.yaml
	-kubectl delete -f voter/voter.yaml
	-kubectl delete -f ballot/ballot.yaml
	-kubectl delete -f ecserver/ecserver.yaml
	-kubectl delete -f election-commission/ec.yaml
