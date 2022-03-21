package ballot

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"log"
	"math/rand"
	"net/http"
)

/*
	func BallotTestResult(req TestReq) string {
		var status string
		fmt.Println("Endpoint Hit:  ballot testResult")
		return status
	}
*/

//RunTest -- test func for ballot
func RunTest(req TestReq) error {

	url := req.IP + ":" + req.Port
	_, result, err := httpClientRequest(http.MethodGet, url, "/", nil)
	if err != nil {
		log.Printf("Failed to get ballot count resp:%s error:%+v", string(result), err)
		return err
	}
	log.Println("get ballot resp:", string(result))
	var initalRespData ballotcountResponse
	if err = json.Unmarshal(result, &initalRespData); err != nil {
		log.Printf("Failed to unmarshal get ballot response. %+v", err)
		return err
	}

	var ballotvotereq ballotvote
	ballotvotereq.CandidateID = fmt.Sprint(rand.Intn(10))
	ballotvotereq.VoterID = fmt.Sprint(rand.Intn(10))
	reqBuff, err := json.Marshal(ballotvotereq)
	if err != nil {
		log.Printf("Failed to marshall post ballot request %+v", err)
		return err
	}
	_, result, err = httpClientRequest(http.MethodPost, url, "/", bytes.NewReader(reqBuff))
	if err != nil {
		log.Printf("Failed to get ballot count resp:%s error:%+v", string(result), err)
		return err
	}
	log.Println("post ballot resp:", string(result))
	var postballotResp ballotstatus
	if err = json.Unmarshal(result, &postballotResp); err != nil {
		log.Printf("Failed to unmarshal post ballot response. %+v", err)
		return err
	}
	if postballotResp.Code != 201 {
		return errors.New("post ballot resp status code")
	}

	_, result, err = httpClientRequest(http.MethodGet, url, "/", nil)
	if err != nil {
		log.Printf("Failed to get final ballot count resp:%s error:%+v", string(result), err)
		return err
	}
	log.Println("get final ballot resp:", string(result))
	var finalRespData ballotcountResponse
	if err = json.Unmarshal(result, &finalRespData); err != nil {
		log.Printf("Failed to unmarshal get final ballot response. %+v", err)
		return err
	}
	log.Println("Endpoint Hit: ballot runTest")
	if finalRespData.TotalVotes-initalRespData.TotalVotes != 1 {
		return errors.New("ballot vote count error")
	}
	return nil
}
