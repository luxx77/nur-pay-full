package api

// feeFor считает комиссию: floor(amount * percent / 100).
//
// Целочисленное деление и даёт нужное округление вниз: при сумме меньше
// 100 теңңе комиссия обнуляется сама, без отдельной проверки.
func feeFor(amount, percent int64) int64 {
	return amount * percent / 100
}
