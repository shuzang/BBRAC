package utils

import (
	"bufio"
	"fmt"
	"math/rand"
	"os"
	"time"
)

// inputDataGenerate generate an input file named timeseries.txt, it include two cols: random time, event number.
func inputDataGenerate() {
	rand.Seed(time.Now().UnixNano())
	// 创建新文件，存放生成的时间序列
	filePath := "./timeseries.txt"
	file, err := os.OpenFile(filePath, os.O_WRONLY|os.O_CREATE, 0666)
	if err != nil {
		fmt.Println("文件打开失败", err)
	}
	defer file.Close()

	// 使用缓冲一次性写入文件
	writeBuffer := bufio.NewWriter(file)
	for i := 0; i < 100; i++ {
		writeBuffer.WriteString(fmt.Sprintf("%f\t%d\n", nextTime(1/5.0), rand.Intn(6)))
	}
	writeBuffer.Flush()
}

func nextTime(rateParameter float64) float64 {
	return rand.ExpFloat64() / rateParameter
}
