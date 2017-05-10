install: all
	go install github.com/google/seesaw/binaries/seesaw_cli
	go install github.com/google/seesaw/binaries/seesaw_ecu
	go install github.com/google/seesaw/binaries/seesaw_engine
	go install github.com/google/seesaw/binaries/seesaw_ha
	go install github.com/google/seesaw/binaries/seesaw_healthcheck
	go install github.com/google/seesaw/binaries/seesaw_ncc
	go install github.com/google/seesaw/binaries/seesaw_watchdog

install-test-tools: all
	go install github.com/google/seesaw/test_tools/healthcheck_test_tool
	go install github.com/google/seesaw/test_tools/ipvs_test_tool
	go install github.com/google/seesaw/test_tools/ncc_test_tool
	go install github.com/google/seesaw/test_tools/quagga_test_tool

proto:
	protoc --go_out=. pb/config/config.proto

test: all
	go test ./...

binaries = seesaw_cli seesaw_ecu seesaw_engine seesaw_ha seesaw_healthcheck seesaw_ncc seesaw_watchdog
$(binaries):
	mkdir -p _output
	cd binaries/$@; go build -x; mv $@ ../../_output/

test_tools = healthcheck_test_tool ipvs_test_tool ncc_test_tool quagga_test_tool
$(test_tools):
	mkdir -p _output
	cd test_tools/$@; go build -x; mv $@ ../../_output/

bins: $(binaries)
tools: $(test_tools)

all: $(binaries) $(test_tools)
