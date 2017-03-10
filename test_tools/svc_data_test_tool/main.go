// Copyright 2017 eBay Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/*
Perform end-to-end tests of the Seesaw NCC component and client.

Note: This needs to talk to the NCC, hence it being a manual testing tool.
*/

package main

import (
	"encoding/hex"
	"flag"
	"log"
	"net"
	"syscall"

	"github.com/google/seesaw/common/seesaw"
	"github.com/google/seesaw/ipvs"
	"github.com/google/seesaw/ncc/client"
)

var (
	nccSocket = flag.String("ncc", seesaw.NCCSocket, "Seesaw NCC socket")
	vipStr    = flag.String("vip", "", "service vip to update")
)

func main() {
	flag.Parse()

	// Connect to the NCC component.
	ncc := client.NewNCC(*nccSocket)
	if err := ncc.Dial(); err != nil {
		log.Fatalf("Failed to connect to NCC: %v", err)
	}

	vip := net.ParseIP(*vipStr)
	log.Printf("Setting service data for vip %s:80 for tbl scheduler", vip)

	svc := &ipvs.Service{
		Address:   vip,
		Protocol:  syscall.IPPROTO_TCP,
		Port:      80,
		Scheduler: "tbl",
	}

	// convert remaining args to byte array
	buf, _ := hex.DecodeString(flag.Arg(0))
	data := &ipvs.ServiceData{
		Version: 1,
		Indices: buf,
	}

	log.Printf("Data version: %d", data.Version)
	log.Printf("Data indices: %s", hex.Dump(data.Indices))

	if err := ncc.IPVSSetServiceData(svc, data); err != nil {
		log.Fatalf("Failed to set service data: %v", err)
	}

	ncc.Close()
	log.Print("Done!")
}
