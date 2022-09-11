
## 한타영타 변환 

* 지원하는 기능
  - 영타로 잘못친 한타를 영타로 수정하기
  - 한타로 잘못친 영타를 한타로 수정하기
  - CAPS LOCK을 누른 채 잘못친 영타 수정하기
  
## dependencies

* `rstudioapi`
* `stringi`
* `KoNLP`
  
## Addsin 등록 확인

R studio 상단을 보면 Addins이 있다.

![Menu](README_insertimage_2.png)

클릭하고 Han2Eng2Han이 있는지 확인하자.

![Addins](README_insertimage_1.png)

여기서 `Han2Eng2Han`는 한타 또는 영타를 영타 또는 한타로 변환하고, `change_case`는 영타의 대소를 바꿔준다.

## Keyboard shortcut 등록

![Modify Keyboard shortcuts](README_insertimage_3.png)

메뉴의 Tools - Modify Keyboard shortcuts를 선택한다.

검색으로 `han`을 치면 다음과 같이 `Han2Eng2Han`과 `change_case`의 단축키를 설정할 수 있다. `[CTRL]+[SHIFT]+[SPACE]`와 `[CTRL]+[SHIFT]+[Q]`로 설정을 권유한다. 하지만 목적과 필요에 따라 수정 가능하다. 하지만 다른 단축키와 겹치지 않도록 주의하자.

![Plot title. ](README_insertimage_4.png)





