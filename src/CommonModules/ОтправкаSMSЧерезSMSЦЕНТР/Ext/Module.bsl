﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// Отправляет SMS через SMS-ЦЕНТР.
//
// Параметры:
//  НомераПолучателей - Массив - номера получателей в формате +7ХХХХХХХХХХ;
//  Текст             - Строка - текст сообщения, длиной не более 480 символов;
//  ИмяОтправителя    - Строка - имя отправителя, которое будет отображаться вместо номера входящего SMS;
//  Логин             - Строка - логин пользователя услуги отправки sms;
//  Пароль            - Строка - пароль пользователя услуги отправки sms.
//
// Возвращаемое значение:
//  Структура: ОтправленныеСообщения - Массив структур: НомерОтправителя.
//                                                  ИдентификаторСообщения.
//             ОписаниеОшибки        - Строка - пользовательское представление ошибки, если пустая строка,
//                                          то ошибки нет.
Функция ОтправитьSMS(НомераПолучателей, Текст, ИмяОтправителя, Логин, Пароль) Экспорт
	
	Результат = Новый Структура("ОтправленныеСообщения,ОписаниеОшибки", Новый Массив, "");
	
	// Подготовка строки получателей.
	СтрокаПолучателей = МассивПолучателейСтрокой(НомераПолучателей);
	
	// Проверка на заполнение обязательных параметров.
	Если ПустаяСтрока(СтрокаПолучателей) Или ПустаяСтрока(Текст) Тогда
		Результат.ОписаниеОшибки = НСтр("ru = 'Неверные параметры сообщения'");
		Возврат Результат;
	КонецЕсли;
	
	// Подготовка параметров запроса.
	ПараметрыЗапроса = Новый Структура;
	ПараметрыЗапроса.Вставить("login", Логин);
	ПараметрыЗапроса.Вставить("psw", Пароль);
	
	ПараметрыЗапроса.Вставить("mes", Текст);
	ПараметрыЗапроса.Вставить("phones", СтрокаПолучателей);
	ПараметрыЗапроса.Вставить("sender", ИмяОтправителя);
	ПараметрыЗапроса.Вставить("fmt", 3); // Ответ в формате JSON.
	ПараметрыЗапроса.Вставить("op", 1); // Выводить информацию по каждому номеру отдельно.
	ПараметрыЗапроса.Вставить("charset", "utf-8");

	// отправка запроса
	ТекстОтвета = ВыполнитьЗапрос("send.php", ПараметрыЗапроса);
	Если Не ЗначениеЗаполнено(ТекстОтвета) Тогда
		Результат.ОписаниеОшибки = Результат.ОписаниеОшибки + НСтр("ru = 'Соединение не установлено'");
		Возврат Результат;
	КонецЕсли;
	
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.УстановитьСтроку(ТекстОтвета);
	ОтветСервера = ПрочитатьJSON(ЧтениеJSON);
	ЧтениеJSON.Закрыть();
	
	Если ОтветСервера.Свойство("error") Тогда
		Результат.ОписаниеОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр(
			"ru = 'Не удалось отправить SMS:
			|%1 (код ошибки: %2)'"), ОписаниеОшибкиОтправки(ОтветСервера["error_code"]), ОтветСервера["error_code"]);
			
		ЗаписьЖурналаРегистрации(НСтр("ru = 'Отправка SMS'", ОбщегоНазначения.КодОсновногоЯзыка()),
			УровеньЖурналаРегистрации.Ошибка, , , Результат.ОписаниеОшибки);
	Иначе
		ИдентификаторСообщения = ОтветСервера["id"];
		Для Каждого СведенияОбОтправке Из ОтветСервера["phones"] Цикл
			НомерПолучателя = ФорматироватьНомер(СведенияОбОтправке["phone"]);
			Если СведенияОбОтправке.Свойство("status") И ЗначениеЗаполнено(СведенияОбОтправке["status"]) Тогда
				Продолжить;
			КонецЕсли;
			ОтправленноеСообщение = Новый Структура("НомерПолучателя,ИдентификаторСообщения", НомерПолучателя,
				"" + НомерПолучателя + "/" + Формат(ИдентификаторСообщения, "ЧГ=0"));
			Результат.ОтправленныеСообщения.Добавить(ОтправленноеСообщение);
		КонецЦикла;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Возвращает текстовое представление статуса доставки сообщения.
//
// Параметры:
//  ИдентификаторСообщения - Строка - идентификатор, присвоенный sms при отправке;
//  НастройкиОтправкиSMS   - Структура - см. ОтправкаSMSПовтИсп.НастройкиОтправкиSMS;
//
// Возвращаемое значение:
//  Строка - статус доставки. См. описание функции ОтправкаSMS.СтатусДоставки.
Функция СтатусДоставки(ИдентификаторСообщения, НастройкиОтправкиSMS) Экспорт
	Логин = НастройкиОтправкиSMS.Логин;
	Пароль = НастройкиОтправкиSMS.Пароль;
	
	ЧастиИдентификатора = СтрРазделить(ИдентификаторСообщения, "/", Истина);
	
	// Подготовка параметров запроса.
	ПараметрыЗапроса = Новый Структура;
	ПараметрыЗапроса.Вставить("login", Логин);
	ПараметрыЗапроса.Вставить("psw", Пароль);
	ПараметрыЗапроса.Вставить("phone", ЧастиИдентификатора[0]);
	ПараметрыЗапроса.Вставить("id", Число(ЧастиИдентификатора[1]));
	ПараметрыЗапроса.Вставить("fmt", 3);
	
	// отправка запроса
	ТекстОтвета = ВыполнитьЗапрос("status.php", ПараметрыЗапроса);
	Если Не ЗначениеЗаполнено(ТекстОтвета) Тогда
		Возврат "Ошибка";
	КонецЕсли;
	
	ЧтениеJSON = Новый ЧтениеJSON;
	ЧтениеJSON.УстановитьСтроку(ТекстОтвета);
	ОтветСервера = ПрочитатьJSON(ЧтениеJSON);
	ЧтениеJSON.Закрыть();
	
	Если ОтветСервера.Свойство("error") Тогда
		ОписаниеОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр(
			"ru = 'Не удалось получить статус доставки SMS (id: ""%3""):
			|%1 (код ошибки: %2)'"), ОписаниеОшибкиПолученияСтатуса(ОтветСервера["error_code"]), ОтветСервера["error_code"], ИдентификаторСообщения);
		ЗаписьЖурналаРегистрации(НСтр("ru = 'Отправка SMS'", ОбщегоНазначения.КодОсновногоЯзыка()),
			УровеньЖурналаРегистрации.Ошибка, , , ОписаниеОшибки);
		Возврат "Ошибка";
	КонецЕсли;
	
	Возврат СтатусДоставкиSMS(ОтветСервера["status"]);
	
КонецФункции

Функция СтатусДоставкиSMS(КодСостояния)
	СоответствиеСтатусов = Новый Соответствие;
	СоответствиеСтатусов.Вставить(-3, "НеОтправлялось");
	СоответствиеСтатусов.Вставить(-1, "Отправляется");
	СоответствиеСтатусов.Вставить(0, "Отправлено");
	СоответствиеСтатусов.Вставить(1, "Доставлено");
	СоответствиеСтатусов.Вставить(3, "НеДоставлено");
	СоответствиеСтатусов.Вставить(20, "НеДоставлено");
	СоответствиеСтатусов.Вставить(22, "НеОтправлено");
	СоответствиеСтатусов.Вставить(23, "НеОтправлено");
	СоответствиеСтатусов.Вставить(24, "НеОтправлено");
	СоответствиеСтатусов.Вставить(25, "НеОтправлено");
	
	Результат = СоответствиеСтатусов[КодСостояния];
	Возврат ?(Результат = Неопределено, "Ошибка", Результат);
КонецФункции

Функция ОписаниеОшибкиОтправки(КодОшибки)
	ОписанияОшибок = Новый Соответствие;
	ОписанияОшибок.Вставить(1, НСтр("ru = 'Ошибка в параметрах.'"));
	ОписанияОшибок.Вставить(2, НСтр("ru = 'Неверный логин или пароль.'"));
	ОписанияОшибок.Вставить(3, НСтр("ru = 'Недостаточно средств на счете.'"));
	ОписанияОшибок.Вставить(4, НСтр("ru = 'IP-адрес временно заблокирован из-за частых ошибок в запросах.Подробнее см. http://smsc.ru/faq/99'"));
	ОписанияОшибок.Вставить(5, НСтр("ru = 'Неверный формат даты.'"));
	ОписанияОшибок.Вставить(6, НСтр("ru = 'Сообщение запрещено (по тексту или по имени отправителя).'"));
	ОписанияОшибок.Вставить(7, НСтр("ru = 'Неверный формат номера телефона.'"));
	ОписанияОшибок.Вставить(8, НСтр("ru = 'Сообщение на указанный номер не может быть доставлено.'"));
	ОписанияОшибок.Вставить(9, НСтр("ru = 'Отправка более одного одинакового запроса на передачу SMS-сообщения в течение минуты.'"));
	
	ТекстСообщения = ОписанияОшибок[КодОшибки];
	Если ТекстСообщения = Неопределено Тогда
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Сообщение не отправлено (код ошибки: %1).'"), КодОшибки);
	КонецЕсли;
	Возврат ТекстСообщения;
КонецФункции

Функция ОписаниеОшибкиПолученияСтатуса(КодОшибки)
	ОписанияОшибок = Новый Соответствие;
	ОписанияОшибок.Вставить(1, НСтр("ru = 'Ошибка в параметрах.'"));
	ОписанияОшибок.Вставить(2, НСтр("ru = 'Неверный логин или пароль.'"));
	ОписанияОшибок.Вставить(5, НСтр("ru = 'Ошибка удаления сообщения.'"));
	ОписанияОшибок.Вставить(4, НСтр("ru = 'IP-адрес временно заблокирован из-за частых ошибок в запросах. Подробнее см. http://smsc.ru/faq/99'"));
	ОписанияОшибок.Вставить(9, НСтр("ru = 'Отправка более пяти запросов на получения статуса одного и того же сообщения в течение минуты.'"));
	
	ТекстСообщения = ОписанияОшибок[КодОшибки];
	Если ТекстСообщения = Неопределено Тогда
		ТекстСообщения = НСтр("ru = 'Отказ выполнения операции'");
	КонецЕсли;
	Возврат ТекстСообщения;
КонецФункции

Функция ВыполнитьЗапрос(ИмяМетода, ПараметрыЗапроса)
	
	HTTPЗапрос = ОтправкаSMS.ПодготовитьHTTPЗапрос("/sys/" + ИмяМетода, ПараметрыЗапроса);
	HTTPОтвет = Неопределено;
	
	Попытка
		Соединение = Новый HTTPСоединение("smsc.ru", , , , ПолучениеФайловИзИнтернета.ПолучитьПрокси("https"), 
			60, ОбщегоНазначенияКлиентСервер.НовоеЗащищенноеСоединение());
		HTTPОтвет = Соединение.ОтправитьДляОбработки(HTTPЗапрос);
	Исключение
		ЗаписьЖурналаРегистрации(НСтр("ru = 'Отправка SMS'", ОбщегоНазначения.КодОсновногоЯзыка()),
			УровеньЖурналаРегистрации.Ошибка, , , ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		Возврат Неопределено;
	КонецПопытки;
	
	Если HTTPОтвет.КодСостояния <> 200 Тогда
		ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Запрос ""%1"" не выполнен. Код состояния: %2.'"), ИмяМетода, HTTPОтвет.КодСостояния) + Символы.ПС
			+ HTTPОтвет.ПолучитьТелоКакСтроку();
		ЗаписьЖурналаРегистрации(НСтр("ru = 'Отправка SMS'", ОбщегоНазначения.КодОсновногоЯзыка()),
			УровеньЖурналаРегистрации.Ошибка, , , ТекстОшибки);
		Возврат Неопределено;
	КонецЕсли;
	
	Если HTTPОтвет <> Неопределено Тогда
		Возврат HTTPОтвет.ПолучитьТелоКакСтроку();
	КонецЕсли;
	
	Возврат Неопределено;
	
КонецФункции

Функция МассивПолучателейСтрокой(Массив)
	Получатели = Новый Массив;
	ОбщегоНазначенияКлиентСервер.ДополнитьМассив(Получатели, Массив, Истина);
	
	Результат = "";
	Для Каждого Получатель Из Получатели Цикл
		Номер = ФорматироватьНомер(Получатель);
		Если НЕ ПустаяСтрока(Номер) Тогда 
			Если Не ПустаяСтрока(Результат) Тогда
				Результат = Результат + ",";
			КонецЕсли;
			Результат = Результат + Номер;
		КонецЕсли;
	КонецЦикла;
	Возврат Результат;
КонецФункции

Функция ФорматироватьНомер(Номер)
	Результат = "";
	ДопустимыеСимволы = "+1234567890";
	Для Позиция = 1 По СтрДлина(Номер) Цикл
		Символ = Сред(Номер,Позиция,1);
		Если СтрНайти(ДопустимыеСимволы, Символ) > 0 Тогда
			Результат = Результат + Символ;
		КонецЕсли;
	КонецЦикла;
	
	Если СтрДлина(Результат) > 10 Тогда
		ПервыйСимвол = Лев(Результат, 1);
		Если ПервыйСимвол = "8" Тогда
			Результат = "+7" + Сред(Результат, 2);
		ИначеЕсли ПервыйСимвол <> "+" Тогда
			Результат = "+" + Результат;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат;
КонецФункции

// Возвращает список разрешений для отправки SMS с использованием всех доступных провайдеров.
//
// Возвращаемое значение:
//  Массив.
//
Функция Разрешения() Экспорт
	
	Протокол = "HTTPS";
	Адрес = "smsc.ru";
	Порт = Неопределено;
	Описание = НСтр("ru = 'Отправка SMS через ""SMS-ЦЕНТР"".'");
	
	МодульРаботаВБезопасномРежиме = ОбщегоНазначения.ОбщийМодуль("РаботаВБезопасномРежиме");
	
	Разрешения = Новый Массив;
	Разрешения.Добавить(
		МодульРаботаВБезопасномРежиме.РазрешениеНаИспользованиеИнтернетРесурса(Протокол, Адрес, Порт, Описание));
	
	Возврат Разрешения;
КонецФункции

Процедура ЗаполнитьОписаниеУслуги(ОписаниеУслуги) Экспорт
	ОписаниеУслуги.АдресВИнтернете = "https://smsc.ru";
КонецПроцедуры

#КонецОбласти

