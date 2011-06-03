RELEASABLE:=true
DEPS:=rabbitmq-server rabbitmq-erlang-client
STANDALONE_TEST_COMMANDS:=eunit:test([rabbit_stomp_test_util,rabbit_stomp_test_frame],[verbose])
WITH_BROKER_TEST_SCRIPTS:=$(PACKAGE_DIR)/test/src/test.py

RABBITMQ_TEST_PATH=../../rabbitmq-test
CERTS_DIR:=$(abspath test/certs)
CAN_RUN_SSL:=$(shell if [ -d $(RABBITMQ_TEST_PATH) ]; then echo "true"; else echo "false"; fi)

TEST_CONFIG_PATH=$(TEST_EBIN_DIR)/test.config
WITH_BROKER_TEST_CONFIG:=$(TEST_EBIN_DIR)/test

ifeq ($(CAN_RUN_SSL),true)

WITH_BROKER_TEST_SCRIPTS += $(PACKAGE_DIR)/test/src/test_ssl.py

$(TEST_CONFIG_PATH): $(CERTS_DIR)
	sed -e "s|%%CERTS_DIR%%|$(CERTS_DIR)|g" < test/src/ssl.config > $@
	echo $(WITH_BROKER_TEST_CONFIG)

$(CERTS_DIR): $(SSL_CONFIG_PATH)
	mkdir -p $(CERTS_DIR)
	make -C $(RABBITMQ_TEST_PATH)/certs all PASSWORD=test DIR=$(CERTS_DIR)

$(SSL_CONFIG_PATH)
else
$(TEST_CONFIG_PATH):
	echo "[]." >> $@
endif

define package_rules

$(PACKAGE_DIR)+pre-test:: $(TEST_CONFIG_PATH)
	make -C $(PACKAGE_DIR)/deps/stomppy

$(PACKAGE_DIR)+clean::
	rm -rf $(CERTS_DIR)

$(PACKAGE_DIR)+clean-with-deps::
	make -C $(PACKAGE_DIR)/deps/stomppy distclean

endef