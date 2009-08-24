package tests.playlist {
	import com.longtailvideo.jwplayer.model.Playlist;
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	
	import org.flexunit.Assert;

	public class PlaylistTest {

		private var list:Playlist;

		[Before]
		public function preTest():void {
			list = new Playlist();
		}

		[Test]
		public function testEmptyList():void {
			Assert.assertNull(list.currentItem);
			Assert.assertEquals(list.currentIndex, -1);
		}

		[Test]
		public function testAddItem():void {
			var item:PlaylistItem = new PlaylistItem();
			list.insertItem(item);
			Assert.assertEquals(list.length, 1);
			Assert.assertEquals(list.getItemAt(0), item);
		}

		[Test]
		public function testRemoveItem():void {
			for (var i:Number = 0; i < 5; i++) {
				list.insertItem(new PlaylistItem(), i);
			}

			for (i = 4; i >= 0; i--) {
				Assert.assertEquals("CurrentIndex should not change", list.currentIndex, 0);
				Assert.assertNotNull("Should have a current item", list.currentItem);
				list.removeItemAt(0);
				Assert.assertEquals("Checking length", list.length, i);
			}

			Assert.assertEquals(list.length, 0);
			Assert.assertEquals(list.currentIndex, -1);
			Assert.assertNull(list.currentItem);
		}

		[Test]
		public function testSetIndex():void {
			list.insertItem(new PlaylistItem());
			list.insertItem(new PlaylistItem());
			list.insertItem(new PlaylistItem());
			Assert.assertEquals(list.currentIndex, 0);

			list.currentIndex = 30;
			Assert.assertEquals(list.currentIndex, 0);

			list.currentIndex = 2;
			Assert.assertEquals(list.currentIndex, 2);

			list.removeItemAt(0);
			Assert.assertEquals(list.currentIndex, 1);
		}

	}
}