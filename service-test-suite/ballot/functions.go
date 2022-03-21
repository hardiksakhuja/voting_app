package ballot

import (
	"errors"
	"fmt"
	"io"
	"io/ioutil"
	"net/http"
	"strings"
)

func httpClientRequest(operation, hostAddr, command string, params io.Reader) (int, []byte, error) {

	url := "http://" + hostAddr + command
	if strings.Contains(hostAddr, "http://") {
		url = hostAddr + command
	}

	req, err := http.NewRequest(operation, url, params)
	if err != nil {
		return http.StatusBadRequest, nil, errors.New("Failed to create HTTP request." + err.Error())
	}

	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
	httpClient := http.Client{}
	resp, err := httpClient.Do(req)
	if err != nil {
		return http.StatusBadRequest, nil, err
	}
	defer resp.Body.Close()

	body, ioErr := ioutil.ReadAll(resp.Body)
	if hBit := resp.StatusCode / 100; hBit != 2 && hBit != 3 {
		if ioErr != nil {
			ioErr = fmt.Errorf("status code error %d", resp.StatusCode)
		}
	}
	return resp.StatusCode, body, ioErr
}
