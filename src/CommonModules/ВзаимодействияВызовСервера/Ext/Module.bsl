﻿///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

////////////////////////////////////////////////////////////////////////////////
//  Основные процедуры и функции поиска контактов.

// Получает представление и всю контактную информацию контакта.
//
// Параметры:
//  Контакт                 - Ссылка - контакт для которого получается информация.
//  Представление           - Строка - в данный параметр будет помещено полученное представление.
//  СтрокаКИ                - Строка - в данный параметр будет помещено полученная контактная информация.
//  ТипКонтактнойИнформации - Перечисления.ТипыКонтактнойИнформации - возможность установить отбор по типу получаемой
//                                                                    контактной информации.
//
Процедура ПредставлениеИВсяКонтактнаяИнформациюКонтакта(Контакт, Представление, СтрокаКИ,ТипКонтактнойИнформации = Неопределено) Экспорт
	
	Представление = "";
	СтрокаКИ = "";
	Если Не ЗначениеЗаполнено(Контакт) 
		ИЛИ ТипЗнч(Контакт) = Тип("СправочникСсылка.СтроковыеКонтактыВзаимодействий") Тогда
		Контакт = Неопределено;
		Возврат;
	КонецЕсли;
	
	ИмяТаблицы = Контакт.Метаданные().Имя;
	ИмяПоляДляНаименованияВладельца = Взаимодействия.ИмяПоляДляНаименованияВладельца(ИмяТаблицы);
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	СправочникКонтакт.Наименование          КАК Наименование,
	|	" + ИмяПоляДляНаименованияВладельца + " КАК НаименованиеВладельца
	|ИЗ
	|	Справочник." + ИмяТаблицы + " КАК СправочникКонтакт
	|ГДЕ
	|	СправочникКонтакт.Ссылка = &Контакт
	|";
	
	Запрос.УстановитьПараметр("Контакт", Контакт);
	Запрос.УстановитьПараметр("ТипКонтактнойИнформации", ТипКонтактнойИнформации);
	Выборка = Запрос.Выполнить().Выбрать();
	Если Не Выборка.Следующий() Тогда
		Возврат;
	КонецЕсли;
	
	Представление = Выборка.Наименование;
	
	Если Не ПустаяСтрока(Выборка.НаименованиеВладельца) Тогда
		Представление = Представление + " (" + Выборка.НаименованиеВладельца + ")";
	КонецЕсли;
	
	МассивКонтактов = ОбщегоНазначенияКлиентСервер.ЗначениеВМассиве(Контакт);
	ТаблицаКИ = УправлениеКонтактнойИнформацией.КонтактнаяИнформацияОбъектов(МассивКонтактов, ТипКонтактнойИнформации, Неопределено, ТекущаяДатаСеанса());
	
	Для Каждого СтрокаТаблицы Из ТаблицаКИ Цикл
		Если СтрокаТаблицы.Тип <> Перечисления.ТипыКонтактнойИнформации.Другое Тогда
			СтрокаКИ = СтрокаКИ + ?(ПустаяСтрока(СтрокаКИ), "", "; ") + СтрокаТаблицы.Представление;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

// Получает наименование и адреса электронной почты контакта.
//
// Параметры:
//  Контакт - Ссылка - контакт, для которого получаются данные.
//
// Возвращаемое значение:
//  Структура - содержит наименование контакта и список значений электронной почты контакта.
//
Функция НаименованиеИАдресаЭлектроннойПочтыКонтакта(Контакт) Экспорт
	
	Если Не ЗначениеЗаполнено(Контакт) 
		Или ТипЗнч(Контакт) = Тип("СправочникСсылка.СтроковыеКонтактыВзаимодействий") Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	МетаданныеКонтакта = Контакт.Метаданные();
	
	Если МетаданныеКонтакта.Иерархический Тогда
		Если Контакт.ЭтоГруппа Тогда
			Возврат Неопределено;
		КонецЕсли;
	КонецЕсли;
	
	МассивОписанияТиповКонтактов = ВзаимодействияКлиентСервер.ОписанияКонтактов();
	ЭлементМассиваОписания = Неопределено;
	Для Каждого ЭлементМассива Из МассивОписанияТиповКонтактов Цикл
		
		Если ЭлементМассива.Имя = МетаданныеКонтакта.Имя Тогда
			ЭлементМассиваОписания = ЭлементМассива;
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
	Если ЭлементМассиваОписания = Неопределено Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	ИмяТаблицы = МетаданныеКонтакта.ПолноеИмя();
	
	ТекстЗапроса =
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
	|	ЕСТЬNULL(ТаблицаКонтактнаяИнформация.АдресЭП,"""") КАК АдресЭП,
	|	СправочникКонтакт." + ЭлементМассиваОписания.ИмяРеквизитаПредставлениеКонтакта + " КАК Наименование
	|ИЗ
	|	" + ИмяТаблицы + " КАК СправочникКонтакт
	|		ЛЕВОЕ СОЕДИНЕНИЕ " + ИмяТаблицы + ".КонтактнаяИнформация КАК ТаблицаКонтактнаяИнформация
	|		ПО (ТаблицаКонтактнаяИнформация.Ссылка = СправочникКонтакт.Ссылка)
	|			И (ТаблицаКонтактнаяИнформация.Тип = ЗНАЧЕНИЕ(Перечисление.ТипыКонтактнойИнформации.АдресЭлектроннойПочты))
	|ГДЕ
	|	СправочникКонтакт.Ссылка = &Контакт
	|ИТОГИ ПО
	|	Наименование";
	
	Запрос = Новый Запрос;
	Запрос.Текст = ТекстЗапроса;
	Запрос.УстановитьПараметр("Контакт", Контакт);
	Выборка = Запрос.Выполнить().Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	
	Если Не Выборка.Следующий() Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Адреса = Новый Структура("Наименование,Адреса", Выборка.Наименование, Новый СписокЗначений);
	ВыборкаАдреса = Выборка.Выбрать();
	Пока ВыборкаАдреса.Следующий() Цикл
		Адреса.Адреса.Добавить(ВыборкаАдреса.АдресЭП);
	КонецЦикла;
	
	Возврат Адреса;
	
КонецФункции

// Получает адреса электронной почты контакта.
//
// Параметры:
//  Контакт - Ссылка - контакт, для которого получаются данные.
//
// Возвращаемое значение:
//  Массив - массив структур содержащих адреса, виды и представления адресов.
//
Функция ПолучитьАдресаЭлектроннойПочтыКонтакта(Контакт, ВключатьНезаполненныеВиды = Ложь) Экспорт
	
	Если Не ЗначениеЗаполнено(Контакт) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	ИмяМетаданныхКонтакта = Контакт.Метаданные().Имя;
	
	Если ВключатьНезаполненныеВиды Тогда
		
		Запрос.Текст =
		"ВЫБРАТЬ
		|	ВидыКонтактнойИнформации.Ссылка КАК Вид,
		|	ВидыКонтактнойИнформации.Наименование КАК ВидНаименование,
		|	Контакты.Ссылка КАК Контакт
		|ПОМЕСТИТЬ КонтактВидыКИ
		|ИЗ
		|	Справочник.ВидыКонтактнойИнформации КАК ВидыКонтактнойИнформации,
		|	Справочник." + ИмяМетаданныхКонтакта + " КАК Контакты
		|ГДЕ
		|	ВидыКонтактнойИнформации.Родитель = &ГруппаВидаКонтактнойИнформации
		|	И Контакты.Ссылка = &Контакт
		|	И ВидыКонтактнойИнформации.Тип = ЗНАЧЕНИЕ(Перечисление.ТипыКонтактнойИнформации.АдресЭлектроннойПочты)
		|;
		|
		|////////////////////////////////////////////////////////////////////////////////
		|ВЫБРАТЬ
		|	Представление(КонтактВидыКИ.Контакт) КАК Представление,
		|	ЕСТЬNULL(КонтактнаяИнформация.АдресЭП, """") КАК АдресЭП,
		|	КонтактВидыКИ.Вид,
		|	КонтактВидыКИ.ВидНаименование
		|ИЗ
		|	КонтактВидыКИ КАК КонтактВидыКИ
		|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник." + ИмяМетаданныхКонтакта + ".КонтактнаяИнформация КАК КонтактнаяИнформация
		|		ПО (КонтактнаяИнформация.Ссылка = КонтактВидыКИ.Контакт)
		|			И (КонтактнаяИнформация.Вид = КонтактВидыКИ.Вид)";
		
		ГруппаВидаКонтактнойИнформации = УправлениеКонтактнойИнформацией.ВидКонтактнойИнформацииПоИмени("Справочник" + ИмяМетаданныхКонтакта);
		Запрос.УстановитьПараметр("ГруппаВидаКонтактнойИнформации", ГруппаВидаКонтактнойИнформации);
	Иначе
		
		Запрос.Текст =
		"ВЫБРАТЬ
		|	Таблицы.АдресЭП,
		|	Таблицы.Вид,
		|	Таблицы.Представление,
		|	Таблицы.Вид.Наименование КАК ВидНаименование
		|ИЗ
		|	Справочник." + ИмяМетаданныхКонтакта + ".КонтактнаяИнформация КАК Таблицы
		|ГДЕ
		|	Таблицы.Ссылка = &Контакт
		|	И Таблицы.Тип = ЗНАЧЕНИЕ(Перечисление.ТипыКонтактнойИнформации.АдресЭлектроннойПочты)";
		
	КонецЕсли;
	
	Запрос.УстановитьПараметр("Контакт", Контакт);
	
	Выборка = Запрос.Выполнить().Выбрать();
	Если Выборка.Количество() = 0 Тогда
		Возврат Новый Массив;
	КонецЕсли;
	
	Результат = Новый Массив;
	Пока Выборка.Следующий() Цикл
		Адрес = Новый Структура;
		Адрес.Вставить("АдресЭП",         Выборка.АдресЭП);
		Адрес.Вставить("Вид",             Выборка.Вид);
		Адрес.Вставить("Представление",   Выборка.Представление);
		Адрес.Вставить("ВидНаименование", Выборка.ВидНаименование);
		Результат.Добавить(Адрес);
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ОтправитьПолучитьПочтуПользователяВФоне(УникальныйИдентификатор) Экспорт
	
	ПараметрыПроцедуры = Новый Структура;
	
	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(УникальныйИдентификатор);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = НСтр("ru = 'Получение и отправка электронной почты пользователя'");
	
	ДлительнаяОперация = ДлительныеОперации.ВыполнитьВФоне("УправлениеЭлектроннойПочтой.ОтправитьЗагрузитьПочтуПользователя",
		ПараметрыПроцедуры,	ПараметрыВыполнения);
	Возврат ДлительнаяОперация;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
//  Прочее

// Устанавливает предмет для массива взаимодействий.
//
// Параметры:
//  МассивВзаимодействий - Массив - массив взаимодействий для которых будет установлен предмет.
//  Предмет  - Ссылка - предмет, на который будет выполнена замена.
//  ПроверятьНаличиеДругихЦепочек - Булево - если Истина, то будет выполнена замена предмета и для взаимодействий,
//                                           которые входят в  цепочки взаимодействий первым взаимодействием которых
//                                           является взаимодействие входящее в массив.
//
Процедура УстановитьПредметДляМассиваВзаимодействий(МассивВзаимодействий, Предмет, ПроверятьНаличиеДругихЦепочек = Ложь) Экспорт

	Если ПроверятьНаличиеДругихЦепочек Тогда
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
		|	ПредметыВзаимодействий.Взаимодействие КАК Ссылка
		|ИЗ
		|	РегистрСведений.ПредметыПапкиВзаимодействий КАК ПредметыВзаимодействий
		|ГДЕ
		|	НЕ (НЕ ПредметыВзаимодействий.Предмет В (&МассивВзаимодействий)
		|			И НЕ ПредметыВзаимодействий.Взаимодействие В (&МассивВзаимодействий))";
		
		Запрос.УстановитьПараметр("МассивВзаимодействий", МассивВзаимодействий);
		МассивВзаимодействий = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
		
	КонецЕсли;
	
	Если ТипЗнч(Предмет) = Тип("РегистрСведенийКлючЗаписи.СостоянияПредметовВзаимодействий") Тогда
		Предмет = Предмет.Предмет;
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ПредметыПапкиВзаимодействий.Предмет
	|ИЗ
	|	РегистрСведений.ПредметыПапкиВзаимодействий КАК ПредметыПапкиВзаимодействий
	|ГДЕ
	|	ПредметыПапкиВзаимодействий.Взаимодействие В(&МассивВзаимодействий)
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	&Предмет";
	
	Запрос.УстановитьПараметр("Предмет", Предмет);
	Запрос.УстановитьПараметр("МассивВзаимодействий", МассивВзаимодействий);
	
	ВыборкаПредметы = Запрос.Выполнить().Выбрать();
	
	Для Каждого Взаимодействие Из МассивВзаимодействий Цикл
		Взаимодействия.УстановитьПредмет(Взаимодействие, Предмет, Ложь);
	КонецЦикла;
	
	Взаимодействия.РассчитатьРассмотреноПоПредметам(Взаимодействия.ТаблицаДанныхДляРасчетаРассмотрено(ВыборкаПредметы, "Предмет"));
	
КонецПроцедуры

// Устанавливает папку электронного письма.
// Параметры:
//  Ссылка  - ссылка на письмо,
//  Папка - устанавливаемая папка электронного письма.
//
Процедура УстановитьПапкуЭлектронногоПисьма(Ссылка, Папка, РассчитыватьРассмотрено = Истина) Экспорт
	
	СтруктураДляЗаписи = РегистрыСведений.ПредметыПапкиВзаимодействий.РеквизитыВзаимодействия();
	СтруктураДляЗаписи.Папка                   = Папка;
	СтруктураДляЗаписи.РассчитыватьРассмотрено = РассчитыватьРассмотрено;
	РегистрыСведений.ПредметыПапкиВзаимодействий.ЗаписатьПредметыПапкиВзаимодействий(Ссылка, СтруктураДляЗаписи);
	
КонецПроцедуры

// Преобразует письмо в двоичные данные и подготавливает к сохранению на диск.
//
// Параметры:
//  Письмо                  - ДокументСсылка.ЭлектронноеПисьмоВходящее,
//                            ДокументСсылка.ЭлектронноеПисьмоИсходящее - письмо, которое подготавливается к сохранению.
//  УникальныйИдентификатор - УникальныйИдентификатор - уникальный идентификатор формы, из которой была вызвана команда сохранения.
//
// Возвращаемое значение:
//  Структура - структура, содержащая подготовленные данные письма.
//
Функция ДанныеПисьмаДляСохраненияКакФайл(Письмо, УникальныйИдентификатор) Экспорт

	ДанныеФайла = СтруктураДанныхФайла();
	
	ДанныеПисьма = Взаимодействия.ИнтернетПочтовоеСообщениеИзПисьма(Письмо);
	Если ДанныеПисьма <> Неопределено Тогда
		
		ДвоичныеДанные = ДанныеПисьма.ИнтернетПочтовоеСообщение.ПолучитьИсходныеДанные();
		ДанныеФайла.СсылкаНаДвоичныеДанныеФайла = ПоместитьВоВременноеХранилище(ДвоичныеДанные, УникальныйИдентификатор);

		ДанныеФайла.Наименование = Взаимодействия.ПредставлениеПисьма(ДанныеПисьма.ИнтернетПочтовоеСообщение.Тема,
			ДанныеПисьма.ДатаПисьма);
		
		ДанныеФайла.Расширение  = "eml";
		ДанныеФайла.ИмяФайла    = ДанныеФайла.Наименование + "." + ДанныеФайла.Расширение;
		ДанныеФайла.Размер      = ДвоичныеДанные.Размер();
		ПапкаДляСохранитьКак = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить("НастройкиПрограммы", "ПапкаДляСохранитьКак");
		ДанныеФайла.Вставить("ПапкаДляСохранитьКак", ПапкаДляСохранитьКак);
		ДанныеФайла.ДатаМодификацииУниверсальная = ТекущаяДатаСеанса();
		ДанныеФайла.ПолноеНаименованияВерсия = ДанныеФайла.ИмяФайла;
		
	КонецЕсли;
	
	Возврат ДанныеФайла;

КонецФункции

Функция РезультатОтправкиПолученияПочтыПользователя(АдресРезультата) Экспорт
	
	Результат = ПолучитьИзВременногоХранилища(АдресРезультата);
	Возврат Результат;
	
КонецФункции

Функция СтруктураДанныхФайла()

	СтруктураДанныхФайла = Новый Структура;
	СтруктураДанныхФайла.Вставить("СсылкаНаДвоичныеДанныеФайла",        "");
	СтруктураДанныхФайла.Вставить("ОтносительныйПуть",                  "");
	СтруктураДанныхФайла.Вставить("ДатаМодификацииУниверсальная",       Дата(1, 1, 1));
	СтруктураДанныхФайла.Вставить("ИмяФайла",                           "");
	СтруктураДанныхФайла.Вставить("Наименование",                       "");
	СтруктураДанныхФайла.Вставить("Расширение",                         "");
	СтруктураДанныхФайла.Вставить("Размер",                             "");
	СтруктураДанныхФайла.Вставить("Редактирует",                        Неопределено);
	СтруктураДанныхФайла.Вставить("ПодписанЭП",                         Ложь);
	СтруктураДанныхФайла.Вставить("Зашифрован",                         Ложь);
	СтруктураДанныхФайла.Вставить("ФайлРедактируется",                  Ложь);
	СтруктураДанныхФайла.Вставить("ФайлРедактируетТекущийПользователь", Ложь);
	СтруктураДанныхФайла.Вставить("ПолноеНаименованияВерсия",           "");
	
	Возврат СтруктураДанныхФайла;

КонецФункции 

#КонецОбласти
