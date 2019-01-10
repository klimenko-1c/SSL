﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// Возвращает сведения о последней проверке версии действующих дат запрета изменения.
//
// Возвращаемое значение:
//  Структура - со свойствами:
//   * Дата - Дата - дата и время последней проверки действующих дат.
//
Функция ПоследняяПроверкаВерсииДействующихДатЗапрета() Экспорт
	
	Возврат Новый Структура("Дата", '00010101');
	
КонецФункции

#КонецОбласти
